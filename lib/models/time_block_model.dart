import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeBlock {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int color;
  final TimeBlockType type;
  final bool isCompleted;
  final String? taskId; // Optional link to existing task
  final DateTime createdAt;

  TimeBlock({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.color = 0xFF2196F3,
    this.type = TimeBlockType.work,
    this.isCompleted = false,
    this.taskId,
    required this.createdAt,
  });

  // Duration of the time block
  Duration get duration {
    final start = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final end = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    return end.difference(start);
  }

  // Get start DateTime
  DateTime get startDateTime {
    return DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  }

  // Get end DateTime
  DateTime get endDateTime {
    return DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
  }

  // Check if time block is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  // Check if time block is upcoming (starts within next hour)
  bool get isUpcoming {
    final now = DateTime.now();
    final oneHourFromNow = now.add(const Duration(hours: 1));
    return startDateTime.isAfter(now) && startDateTime.isBefore(oneHourFromNow);
  }

  // Check if time block is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(endDateTime) && !isCompleted;
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'color': color,
      'type': type.index,
      'isCompleted': isCompleted,
      'taskId': taskId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore DocumentSnapshot
  factory TimeBlock.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse time strings
    final startTimeParts = data['startTime'].split(':');
    final endTimeParts = data['endTime'].split(':');
    
    return TimeBlock(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      color: data['color'] as int? ?? 0xFF2196F3,
      type: TimeBlockType.values[data['type'] as int? ?? 0],
      isCompleted: data['isCompleted'] ?? false,
      taskId: data['taskId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with method for updates
  TimeBlock copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? color,
    TimeBlockType? type,
    bool? isCompleted,
    String? taskId,
    DateTime? createdAt,
  }) {
    return TimeBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      taskId: taskId ?? this.taskId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Format time for display
  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Get display time range
  String get timeRange {
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }
}

enum TimeBlockType {
  work,
  personal,
  meeting,
  breakTime,
  exercise,
  study,
  other,
}

extension TimeBlockTypeExtension on TimeBlockType {
  String get displayName {
    switch (this) {
      case TimeBlockType.work:
        return 'Work';
      case TimeBlockType.personal:
        return 'Personal';
      case TimeBlockType.meeting:
        return 'Meeting';
      case TimeBlockType.breakTime:
        return 'Break';
      case TimeBlockType.exercise:
        return 'Exercise';
      case TimeBlockType.study:
        return 'Study';
      case TimeBlockType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TimeBlockType.work:
        return Icons.work;
      case TimeBlockType.personal:
        return Icons.person;
      case TimeBlockType.meeting:
        return Icons.people;
      case TimeBlockType.breakTime:
        return Icons.coffee;
      case TimeBlockType.exercise:
        return Icons.fitness_center;
      case TimeBlockType.study:
        return Icons.school;
      case TimeBlockType.other:
        return Icons.category;
    }
  }

  Color get defaultColor {
    switch (this) {
      case TimeBlockType.work:
        return const Color(0xFF2196F3); // Blue
      case TimeBlockType.personal:
        return const Color(0xFF4CAF50); // Green
      case TimeBlockType.meeting:
        return const Color(0xFFFF9800); // Orange
      case TimeBlockType.breakTime:
        return const Color(0xFF9C27B0); // Purple
      case TimeBlockType.exercise:
        return const Color(0xFFE91E63); // Pink
      case TimeBlockType.study:
        return const Color(0xFF607D8B); // Blue Grey
      case TimeBlockType.other:
        return const Color(0xFF795548); // Brown
    }
  }
}
