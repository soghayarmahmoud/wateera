import 'package:flutter/material.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'notes_screen.dart';
import 'tasks_screen.dart';
import 'pomodoro_screen.dart';
import 'goals_screen.dart';

class AllInOneScreen extends StatelessWidget {
  const AllInOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WateeraAppBar(title: Text('All In One')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMenuButton(
              context,
              title: 'Notes',
              color: Colors.blue,
              icon: Icons.note,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'To-do',
              color: Colors.green,
              icon: Icons.check_circle_outline,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TasksScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'Pomodoro',
              color: Colors.orange,
              icon: Icons.timer,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              title: 'Goals',
              color: Colors.purple,
              icon: Icons.flag,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required String title, required Color color, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}