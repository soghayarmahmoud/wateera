
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/services/notification_service.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  late AuthProvider _authProvider;

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _fetchTasks();
  }

  CollectionReference get _tasksCollection => _firestore
      .collection('users')
      .doc(_authProvider.user!.uid)
      .collection('tasks');

  Future<void> _fetchTasks() async {
    if (_authProvider.user == null) return;

    _tasksCollection.snapshots().listen((snapshot) {
      _tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      scheduleTaskReminders();
      notifyListeners();
    });
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  Future<void> addTask(Task task) async {
    if (_authProvider.user == null) return;
    await _tasksCollection.doc(task.id).set(task.toJson());
  }

  Future<void> updateTask(Task updatedTask) async {
    if (_authProvider.user == null) return;
    await _tasksCollection.doc(updatedTask.id).update(updatedTask.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    if (_authProvider.user == null) return;
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    if (_authProvider.user == null) return;
    final task = _tasks.firstWhere((task) => task.id == taskId);
    task.isCompleted = !task.isCompleted;
    await _tasksCollection.doc(taskId).update({'isCompleted': task.isCompleted});
  }

  int get completedTasksCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  void scheduleTaskReminders() {
    final now = DateTime.now();
    for (var task in _tasks) {
      if (!task.isCompleted) {
        final timeParts = task.startTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final taskDateTime = DateTime(task.date.year, task.date.month, task.date.day, hour, minute);

        if (taskDateTime.isAfter(now)) {
          final reminderTime = taskDateTime.subtract(const Duration(minutes: 15));
          if (reminderTime.isAfter(now)) {
            _notificationService.scheduleNotification(
              task.id.hashCode,
              'Task Reminder',
              'Your task "${task.title}" is starting in 15 minutes.',
              reminderTime,
            );
          }
        }
      }
    }
  }
}
