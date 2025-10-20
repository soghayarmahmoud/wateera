import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  bool isCompleted;
  final int color;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    this.color = 0xFF2196F3,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'isCompleted': isCompleted,
      'color': color,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'],
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'],
      endTime: data['endTime'],
      isCompleted: data['isCompleted'] ?? false,
      color: data['color'] as int? ?? 0xFF2196F3,
    );
  }

  // Copy with method for updates
  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isCompleted,
    int? color,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
    );
  }
}