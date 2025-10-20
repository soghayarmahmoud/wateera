import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color = 0xFFFFFFFF,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      color: data['color'] as int? ?? 0xFFFFFFFF,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? color,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}