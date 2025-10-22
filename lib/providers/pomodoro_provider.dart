import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wateera/providers/user_provider.dart';
import 'package:wateera/services/notification_service.dart';

class PomodoroProvider extends ChangeNotifier {
  int _selectedMinutes = 25;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  UserProvider? _userProvider;
  final NotificationService _notificationService = NotificationService();

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  int get selectedMinutes => _selectedMinutes;

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    return _remainingSeconds / _totalSeconds;
  }

  void setSelectedMinutes(int minutes) {
    _selectedMinutes = minutes;
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  // Start timer
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeSession();
        _notificationService.showNotification(
            'Pomodoro Session Ended', 'Time for a break!');
      }
    });
    notifyListeners();
  }

  // Pause timer
  void pause() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Reset timer
  void reset() {
    _isRunning = false;
    _timer?.cancel();
    _remainingSeconds = _selectedMinutes * 60;
    notifyListeners();
  }

  // Stop timer
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Complete session with XP reward
  void _completeSession() async {
    _isRunning = false;
    _timer?.cancel();
    
    // Award XP for completing a Pomodoro session
    if (_userProvider != null) {
      await _userProvider!.awardPomodoroXP();
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
