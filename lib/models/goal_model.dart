import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime endTime;
  bool isCompleted;
  final int color;
  final GoalPriority priority;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    required this.endTime,
    this.isCompleted = false,
    this.color = 0xFF4CAF50,
    this.priority = GoalPriority.medium,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'endTime': Timestamp.fromDate(endTime),
      'isCompleted': isCompleted,
      'color': color,
      'priority': priority.index,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      color: data['color'] as int? ?? 0xFF4CAF50,
      priority: GoalPriority.values[data['priority'] as int? ?? 1],
    );
  }

  // Copy with method for updates
  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? endTime,
    bool? isCompleted,
    int? color,
    GoalPriority? priority,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }

  // Get days remaining
  int get daysRemaining {
    final now = DateTime.now();
    final difference = endTime.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  // Check if goal is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(endTime) && !isCompleted;
  }

  // Get priority color
  Color get priorityColor {
    switch (priority) {
      case GoalPriority.low:
        return Colors.green;
      case GoalPriority.medium:
        return Colors.orange;
      case GoalPriority.high:
        return Colors.red;
    }
  }
}

enum GoalPriority {
  low,
  medium,
  high,
}

extension GoalPriorityExtension on GoalPriority {
  String get displayName {
    switch (this) {
      case GoalPriority.low:
        return 'Low';
      case GoalPriority.medium:
        return 'Medium';
      case GoalPriority.high:
        return 'High';
    }
  }
}