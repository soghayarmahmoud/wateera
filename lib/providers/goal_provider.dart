import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wateera/models/goal_model.dart';
import 'package:wateera/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class GoalProvider extends ChangeNotifier {
  late Box<Goal> _goalBox;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  GoalProvider() {
    _goalBox = Hive.box<Goal>('goals');
    scheduleGoalNotifications();
  }

  List<Goal> get goals => _goalBox.values.toList();

  void addGoal(String title, DateTime endTime) {
    final newGoal = Goal(
      id: _uuid.v4(),
      title: title,
      endTime: endTime,
    );
    _goalBox.put(newGoal.id, newGoal);
    scheduleGoalNotifications();
    notifyListeners();
  }

  void updateGoal(Goal updatedGoal) {
    _goalBox.put(updatedGoal.id, updatedGoal);
    scheduleGoalNotifications();
    notifyListeners();
  }

  void deleteGoal(String goalId) {
    _goalBox.delete(goalId);
    notifyListeners();
  }

  void toggleGoalCompletion(String goalId) {
    final goal = _goalBox.get(goalId);
    if (goal != null) {
      goal.isCompleted = !goal.isCompleted;
      _goalBox.put(goalId, goal);
      notifyListeners();
    }
  }

  void scheduleGoalNotifications() {
    final now = DateTime.now();
    for (var goal in _goalBox.values) {
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
