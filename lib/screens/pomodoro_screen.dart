import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wateera/providers/pomodoro_provider.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PomodoroProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 13.0,
              percent: provider.progress,
              center: Text(
                provider.formattedTime,
                style: const TextStyle(fontSize: 40),
              ),
              progressColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!provider.isRunning)
                  ElevatedButton(
                    onPressed: provider.start,
                    child: const Text('Start'),
                  )
                else
                  ElevatedButton(
                    onPressed: provider.pause,
                    child: const Text('Pause'),
                  ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: provider.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Duration: ${provider.selectedMinutes} minutes'),
            Slider(
              value: provider.selectedMinutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: provider.selectedMinutes.toString(),
              onChanged: (value) {
                provider.setSelectedMinutes(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }
}