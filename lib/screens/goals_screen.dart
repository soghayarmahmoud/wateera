
import 'package:flutter/material.dart';
import 'package:wateera/components/wateera_app_bar.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WateeraAppBar(title: Text('Goals')),
      body: const Center(
        child: Text('Goals Screen'),
      ),
    );
  }
}
