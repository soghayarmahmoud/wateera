import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wateera/services/notification_service.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  final NotificationService _notificationService = NotificationService();

  TaskProvider() {
    _taskBox = Hive.box<Task>('tasks');
    scheduleTaskReminders();
  }

  List<Task> get tasks => _taskBox.values.toList();

  List<Task> getTasksForDate(DateTime date) {
    return _taskBox.values.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  void addTask(Task task) {
    _taskBox.put(task.id, task);
    scheduleTaskReminders();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    _taskBox.put(updatedTask.id, updatedTask);
    scheduleTaskReminders();
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _taskBox.delete(taskId);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final task = _taskBox.get(taskId);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      _taskBox.put(taskId, task);
      notifyListeners();
    }
  }

  int get completedTasksCount {
    return _taskBox.values.where((task) => task.isCompleted).length;
  }

  void scheduleTaskReminders() {
    final now = DateTime.now();
    for (var task in _taskBox.values) {
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