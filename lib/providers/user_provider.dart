import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? get currentUser => _currentUser;
  int get currentXP => _currentUser?.xp ?? 0;
  int get currentLevel => _currentUser?.level ?? 1;
  String get levelTitle => _currentUser?.levelTitle ?? 'Beginner';
  double get levelProgress => _currentUser?.levelProgress ?? 0.0;

  // Initialize user data
  Future<void> initializeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _loadOrCreateUser(user);
    }
  }

  // Load or create user in Firestore
  Future<void> _loadOrCreateUser(User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        // Update last active time
        await _updateLastActive();
      } else {
        // Create new user
        _currentUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toJson());
        
        // Award daily login XP for new user
        await addXP(XPRewards.dailyLogin);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading/creating user: $e');
    }
  }

  // Add XP and update level
  Future<void> addXP(int points) async {
    if (_currentUser == null) return;

    final newXP = _currentUser!.xp + points;
    final newLevel = UserModel.calculateLevel(newXP);
    
    final updatedUser = _currentUser!.copyWith(
      xp: newXP,
      level: newLevel,
      lastActiveAt: DateTime.now(),
    );

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'xp': newXP,
        'level': newLevel,
        'lastActiveAt': Timestamp.fromDate(DateTime.now()),
      });

      // Check if user leveled up
      bool leveledUp = newLevel > _currentUser!.level;
      _currentUser = updatedUser;
      
      notifyListeners();

      // Show level up notification if applicable
      if (leveledUp) {
        _showLevelUpNotification(newLevel);
      }
    } catch (e) {
      debugPrint('Error adding XP: $e');
    }
  }

  // Update last active time
  Future<void> _updateLastActive() async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'lastActiveAt': Timestamp.fromDate(DateTime.now()),
      });
      
      _currentUser = _currentUser!.copyWith(lastActiveAt: DateTime.now());
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating last active: $e');
    }
  }

  // Show level up notification (you can customize this)
  void _showLevelUpNotification(int newLevel) {
    // This could trigger a snackbar, dialog, or custom notification
    debugPrint('🎉 Level Up! You are now level $newLevel!');
  }

  // Award XP for different actions
  Future<void> awardNoteXP() async {
    await addXP(XPRewards.addNote);
  }

  Future<void> awardTaskCompletionXP() async {
    await addXP(XPRewards.completeTask);
  }

  Future<void> awardGoalCompletionXP() async {
    await addXP(XPRewards.completeGoal);
  }

  Future<void> awardPomodoroXP() async {
    await addXP(XPRewards.pomodoroSession);
  }

  Future<void> awardDailyLoginXP() async {
    if (_currentUser == null) return;
    
    // Check if user already got daily login XP today
    final now = DateTime.now();
    final lastActive = _currentUser!.lastActiveAt;
    
    if (now.day != lastActive.day || 
        now.month != lastActive.month || 
        now.year != lastActive.year) {
      await addXP(XPRewards.dailyLogin);
    }
  }

  // Reset user data (for testing or admin purposes)
  Future<void> resetUserProgress() async {
    if (_currentUser == null) return;

    try {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'xp': 0,
        'level': 1,
      });

      _currentUser = _currentUser!.copyWith(xp: 0, level: 1);
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting user progress: $e');
    }
  }

  // Clear user data on logout
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
