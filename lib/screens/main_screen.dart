import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wateera/components/custom_nav_bar.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/models/goal_model.dart';
import 'package:wateera/providers/goal_provider.dart';
import 'package:wateera/providers/note_provider.dart';
import 'package:wateera/providers/task_provider.dart';
import 'package:wateera/screens/ai_assistant_screen.dart';
import 'package:wateera/screens/all_in_one_screen.dart';
import 'package:wateera/screens/pomodoro_screen.dart';
import 'package:wateera/services/notification_service.dart';

import 'calendar_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Default to home screen

  final List<Widget> _screens = [
    const AiAssistantScreen(),
    const AllInOneScreen(),
    const CalendarScreen(),
    const PomodoroScreen(),
    const SettingsScreen(),
  ];

  final List<String> _screenTitles = [
    'AI Assistant',
    'All-In-One',
    'Calendar',
    'Pomodoro',
    'Settings',
  ];
  @override
  void initState() {
    super.initState();
    // It's better to schedule this from main.dart or a service that runs on app startup
    // to ensure it's set reliably. Calling it here is okay for demonstration.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleDailyNotification();
    });
  }

  void _scheduleDailyNotification() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(
      context,
      listen: false,
    ); // Corrected
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final now = DateTime.now();
    final taskCount = taskProvider.getTasksForDate(now).length;
    final goalCount = goalProvider.goals
        .where((goal) => isSameDay(goal.endTime, now))
        .length;
    final noteCount = noteProvider.getNotesForDate(now).length;

    await NotificationService().scheduleDailySummaryNotification(
      taskCount,
      goalCount,
      noteCount,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: WateeraAppBar(title: Text(_screenTitles[_selectedIndex])),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: _selectedIndex == 2
            ? Theme.of(context).primaryColor
            : Colors.grey,
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
