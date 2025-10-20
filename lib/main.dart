import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/models/goal_model.dart';
import 'package:wateera/models/task_model.dart';
import 'package:wateera/providers/ai_assistant_provider.dart';
import 'package:wateera/providers/goal_provider.dart';
import 'package:wateera/splash_screen.dart';
import 'providers/task_provider.dart';
import 'providers/note_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:wateera/models/note_model.dart';
import 'package:wateera/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().init();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(GoalAdapter());
  await Hive.deleteBoxFromDisk('tasks');
  await Hive.openBox<Task>('tasks');
  await Hive.deleteBoxFromDisk('notes');
  await Hive.openBox<Note>('notes');
  await Hive.deleteBoxFromDisk('goals');
  await Hive.openBox<Goal>('goals');

  runApp(const WateeraApp());
}

class WateeraApp extends StatelessWidget {
  const WateeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Wateera',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(Brightness.light, themeProvider.primaryColor),
            darkTheme: AppTheme.getTheme(Brightness.dark, themeProvider.primaryColor),
            themeMode: themeProvider.themeMode,
            home: const AnimatedSplashScreen(),
          );
        },
      ),
    );
  }
}
