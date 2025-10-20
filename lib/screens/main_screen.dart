import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/custom_nav_bar.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/screens/ai_assistant_screen.dart';
import 'package:wateera/screens/all_in_one_screen.dart';
import 'package:wateera/screens/pomodoro_screen.dart';
import '../providers/theme_provider.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: WateeraAppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFA7F3D0)],
          ).createShader(bounds),
          child: const Text(
            'Wateera',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: _selectedIndex == 2 ? Theme.of(context).primaryColor : Colors.grey,
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