import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wateera/providers/ai_assistant_provider.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/providers/goal_provider.dart';
import 'package:wateera/providers/note_provider.dart';
import 'package:wateera/providers/pomodoro_provider.dart';
import 'package:wateera/providers/task_provider.dart';
import 'package:wateera/providers/theme_provider.dart';
import 'package:wateera/splash_screen.dart';
import 'package:wateera/theme/app_theme.dart';
import 'package:wateera/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  tz.initializeTimeZones();
  await NotificationService().init();

  runApp(const WateeraApp());
}

class WateeraApp extends StatelessWidget {
  const WateeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => TaskProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NoteProvider>(
          create: (context) => NoteProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => NoteProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (context) => GoalProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => GoalProvider(auth),
        ),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
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