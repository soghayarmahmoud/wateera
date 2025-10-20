import 'package:flutter/material.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/screens/ai_assistant_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WateeraAppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
                );
              },
              child: const Text('Go to AI Assistant'),
            ),
          ],
        ),
      ),
    );
  }
}