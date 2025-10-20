import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final DateTime endTime;
  bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.endTime,
    this.isCompleted = false,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'endTime': Timestamp.fromDate(endTime),
      'isCompleted': isCompleted,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Goal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      title: data['title'],
      endTime: (data['endTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}