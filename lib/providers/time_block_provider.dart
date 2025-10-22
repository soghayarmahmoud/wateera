import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wateera/models/time_block_model.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/providers/user_provider.dart';
import 'package:wateera/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TimeBlockProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();
  late AuthProvider _authProvider;
  UserProvider? _userProvider;

  List<TimeBlock> _timeBlocks = [];
  DateTime _selectedDate = DateTime.now();

  List<TimeBlock> get timeBlocks => _timeBlocks;
  DateTime get selectedDate => _selectedDate;

  TimeBlockProvider(AuthProvider authProvider, [List<TimeBlock>? initialTimeBlocks]) {
    _authProvider = authProvider;
    _timeBlocks = initialTimeBlocks ?? [];
    _fetchTimeBlocks();
  }

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider.user != null) {
      _fetchTimeBlocks();
    } else {
      _timeBlocks = [];
    }
    notifyListeners();
  }

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  CollectionReference get _timeBlocksCollection => _firestore
      .collection('users')
      .doc(_authProvider.user!.uid)
      .collection('timeBlocks');

  Future<void> _fetchTimeBlocks() async {
    if (_authProvider.user == null) return;

    _timeBlocksCollection.snapshots().listen((snapshot) {
      _timeBlocks = snapshot.docs.map((doc) => TimeBlock.fromFirestore(doc)).toList();
      _scheduleNotifications();
      notifyListeners();
    });
  }

  // Get time blocks for a specific date
  List<TimeBlock> getTimeBlocksForDate(DateTime date) {
    return _timeBlocks.where((block) {
      return block.date.year == date.year &&
          block.date.month == date.month &&
          block.date.day == date.day;
    }).toList()..sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));
  }

  // Get active time block (currently running)
  TimeBlock? get activeTimeBlock {
    final now = DateTime.now();
    return _timeBlocks.where((block) => block.isActive).firstOrNull;
  }

  // Get upcoming time blocks (next 2 hours)
  List<TimeBlock> get upcomingTimeBlocks {
    final now = DateTime.now();
    final twoHoursFromNow = now.add(const Duration(hours: 2));
    
    return _timeBlocks.where((block) {
      return block.startDateTime.isAfter(now) && 
             block.startDateTime.isBefore(twoHoursFromNow);
    }).toList()..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Add new time block
  Future<void> addTimeBlock(TimeBlock timeBlock) async {
    if (_authProvider.user == null) return;

    // Check for conflicts
    if (_hasTimeConflict(timeBlock)) {
      throw Exception('Time block conflicts with existing block');
    }

    await _timeBlocksCollection.doc(timeBlock.id).set(timeBlock.toJson());
    await _notificationService.showNotification(
      'Time Block Created',
      'New time block: ${timeBlock.title}',
    );
  }

  // Update time block
  Future<void> updateTimeBlock(TimeBlock updatedTimeBlock) async {
    if (_authProvider.user == null) return;

    // Check for conflicts (excluding the current block)
    if (_hasTimeConflict(updatedTimeBlock, excludeId: updatedTimeBlock.id)) {
      throw Exception('Time block conflicts with existing block');
    }

    await _timeBlocksCollection.doc(updatedTimeBlock.id).update(updatedTimeBlock.toJson());
    await _notificationService.showNotification(
      'Time Block Updated',
      'Updated: ${updatedTimeBlock.title}',
    );
  }

  // Delete time block
  Future<void> deleteTimeBlock(String timeBlockId) async {
    if (_authProvider.user == null) return;
    await _timeBlocksCollection.doc(timeBlockId).delete();
  }

  // Toggle completion status
  Future<void> toggleTimeBlockCompletion(String timeBlockId) async {
    if (_authProvider.user == null) return;
    
    final timeBlock = _timeBlocks.firstWhere((block) => block.id == timeBlockId);
    final wasCompleted = timeBlock.isCompleted;
    final updatedTimeBlock = timeBlock.copyWith(isCompleted: !timeBlock.isCompleted);
    
    await _timeBlocksCollection.doc(timeBlockId).update({
      'isCompleted': updatedTimeBlock.isCompleted,
    });

    // Award XP for completing time blocks
    if (!wasCompleted && updatedTimeBlock.isCompleted && _userProvider != null) {
      await _userProvider!.addXP(10); // 10 XP for completing a time block
    }
  }

  // Move time block (drag and drop functionality)
  Future<void> moveTimeBlock(String timeBlockId, TimeOfDay newStartTime) async {
    if (_authProvider.user == null) return;

    final timeBlock = _timeBlocks.firstWhere((block) => block.id == timeBlockId);
    final duration = timeBlock.duration;
    final newEndTime = TimeOfDay(
      hour: (newStartTime.hour * 60 + newStartTime.minute + duration.inMinutes) ~/ 60,
      minute: (newStartTime.hour * 60 + newStartTime.minute + duration.inMinutes) % 60,
    );

    final updatedTimeBlock = timeBlock.copyWith(
      startTime: newStartTime,
      endTime: newEndTime,
    );

    // Check for conflicts
    if (_hasTimeConflict(updatedTimeBlock, excludeId: timeBlockId)) {
      throw Exception('Cannot move: conflicts with existing block');
    }

    await updateTimeBlock(updatedTimeBlock);
    await _notificationService.showNotification(
      'Time Block Moved',
      '${timeBlock.title} moved to ${updatedTimeBlock.timeRange}',
    );
  }

  // Check for time conflicts
  bool _hasTimeConflict(TimeBlock newBlock, {String? excludeId}) {
    final blocksOnSameDate = getTimeBlocksForDate(newBlock.date)
        .where((block) => excludeId == null || block.id != excludeId);

    for (final existingBlock in blocksOnSameDate) {
      // Check if times overlap
      if (_timesOverlap(
        newBlock.startTime, newBlock.endTime,
        existingBlock.startTime, existingBlock.endTime,
      )) {
        return true;
      }
    }
    return false;
  }

  // Check if two time ranges overlap
  bool _timesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Minutes = start1.hour * 60 + start1.minute;
    final end1Minutes = end1.hour * 60 + end1.minute;
    final start2Minutes = start2.hour * 60 + start2.minute;
    final end2Minutes = end2.hour * 60 + end2.minute;

    return start1Minutes < end2Minutes && start2Minutes < end1Minutes;
  }

  // Schedule notifications for time blocks
  void _scheduleNotifications() {
    final now = DateTime.now();
    
    for (final timeBlock in _timeBlocks) {
      if (timeBlock.startDateTime.isAfter(now) && !timeBlock.isCompleted) {
        // Schedule start notification
        _notificationService.scheduleNotification(
          timeBlock.id.hashCode,
          'Time Block Starting',
          '${timeBlock.title} is starting now',
          timeBlock.startDateTime,
        );

        // Schedule 5-minute warning
        final warningTime = timeBlock.startDateTime.subtract(const Duration(minutes: 5));
        if (warningTime.isAfter(now)) {
          _notificationService.scheduleNotification(
            timeBlock.id.hashCode + 1,
            'Time Block Reminder',
            '${timeBlock.title} starts in 5 minutes',
            warningTime,
          );
        }
      }
    }
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final today = DateTime.now();
    final todayBlocks = getTimeBlocksForDate(today);
    final completedToday = todayBlocks.where((block) => block.isCompleted).length;
    final totalToday = todayBlocks.length;
    
    return {
      'totalToday': totalToday,
      'completedToday': completedToday,
      'completionRate': totalToday > 0 ? (completedToday / totalToday) : 0.0,
      'activeBlock': activeTimeBlock,
      'upcomingCount': upcomingTimeBlocks.length,
    };
  }

  // Create time block from existing task
  Future<void> createTimeBlockFromTask(String taskId, String taskTitle, DateTime taskDate, 
      String startTime, String endTime) async {
    final startTimeParts = startTime.split(':');
    final endTimeParts = endTime.split(':');
    
    final timeBlock = TimeBlock(
      id: _uuid.v4(),
      title: taskTitle,
      description: 'Created from task',
      date: taskDate,
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      type: TimeBlockType.work,
      taskId: taskId,
      createdAt: DateTime.now(),
    );

    await addTimeBlock(timeBlock);
  }
}

extension on List<TimeBlock> {
  TimeBlock? get firstOrNull => isEmpty ? null : first;
}
