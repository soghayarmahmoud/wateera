import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final int xp;
  final int level;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.xp = 0,
    this.level = 1,
    required this.createdAt,
    required this.lastActiveAt,
  });

  // Calculate level based on XP
  static int calculateLevel(int xp) {
    // Level progression: 100 XP for level 1, 200 for level 2, etc.
    // Formula: level = floor(sqrt(xp / 50)) + 1
    if (xp < 100) return 1;
    return (xp ~/ 100) + 1;
  }

  // Calculate XP needed for next level
  int get xpForNextLevel {
    return level * 100;
  }

  // Calculate XP progress in current level
  int get xpInCurrentLevel {
    return xp - ((level - 1) * 100);
  }

  // Calculate progress percentage for current level
  double get levelProgress {
    int currentLevelXp = xpInCurrentLevel;
    int xpNeeded = 100; // Each level needs 100 XP
    return currentLevelXp / xpNeeded;
  }

  // Get level title based on XP
  String get levelTitle {
    if (level <= 5) return 'Beginner';
    if (level <= 10) return 'Novice';
    if (level <= 20) return 'Intermediate';
    if (level <= 35) return 'Advanced';
    if (level <= 50) return 'Expert';
    if (level <= 75) return 'Master';
    if (level <= 100) return 'Grandmaster';
    return 'Legend';
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'xp': xp,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
    };
  }

  // Create from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    int? xp,
    int? level,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

// XP reward constants
class XPRewards {
  static const int addNote = 10;
  static const int completeTask = 25;
  static const int completeGoal = 50;
  static const int pomodoroSession = 15;
  static const int dailyLogin = 5;
}
