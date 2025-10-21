import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/models/goal_model.dart';
import 'package:wateera/services/notification_service.dart';
import 'package:uuid/uuid.dart';

const int GOAL_BONUS_POINTS = 20; // Define bonus points for adding a goal

class GoalProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();
  late AuthProvider _authProvider;

  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  GoalProvider(AuthProvider authProvider, [List<Goal>? initialGoals]) {
    _authProvider = authProvider;
    _goals = initialGoals ?? [];
    _fetchGoals();
  }

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider.user != null) {
      _fetchGoals();
    } else {
      _goals = [];
    }
    notifyListeners();
  }

  CollectionReference get _goalsCollection => _firestore
      .collection('users')
      .doc(_authProvider.user!.uid)
      .collection('goals');

  Future<void> _fetchGoals() async {
    if (_authProvider.user == null) return;

    _goalsCollection.snapshots().listen((snapshot) {
      _goals = snapshot.docs.map((doc) => Goal.fromFirestore(doc)).toList();
      scheduleGoalNotifications();
      notifyListeners();
    });
  }

  Future<void> addGoal(String title, DateTime endTime) async {
    if (_authProvider.user == null) return;
    final newGoal = Goal(id: _uuid.v4(), title: title, endTime: endTime);
    await _goalsCollection.doc(newGoal.id).set(newGoal.toJson());
    await _notificationService.showNotification(
      'New Goal Added',
      'You have a new goal: ${newGoal.title}',
    );
    await _authProvider.addPoints(GOAL_BONUS_POINTS); // Add bonus points
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    if (_authProvider.user == null) return;
    await _goalsCollection.doc(updatedGoal.id).update(updatedGoal.toJson());
  }

  Future<void> deleteGoal(String goalId) async {
    if (_authProvider.user == null) return;
    await _goalsCollection.doc(goalId).delete();
  }

  Future<void> toggleGoalCompletion(String goalId) async {
    if (_authProvider.user == null) return;
    final goal = _goals.firstWhere((goal) => goal.id == goalId);
    goal.isCompleted = !goal.isCompleted;
    await _goalsCollection.doc(goalId).update({
      'isCompleted': goal.isCompleted,
    });
  }

  void scheduleGoalNotifications() {
    final now = DateTime.now();
    for (var goal in _goals) {
      if (!goal.isCompleted && goal.endTime.isAfter(now)) {
        _notificationService.scheduleNotification(
          goal.id.hashCode,
          'Goal Deadline',
          'Your goal "${goal.title}" is due now.',
          goal.endTime,
        );
      }
    }
  }
}
