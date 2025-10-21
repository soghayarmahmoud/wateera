import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
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
  await _requestExactAlarmPermission();

  runApp(const WateeraApp());
}

class WateeraApp extends StatelessWidget {
  const WateeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Providers مستقلة (لا تعتمد على غيرها)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),

        // 2. Providers تعتمد على AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(
            context.read<AuthProvider>(), // استخدم .read أفضل
            [],
          ),
          update: (context, auth, previous) {
            previous!.updateAuthProvider(auth);
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NoteProvider>(
          create: (context) => NoteProvider(
            context.read<AuthProvider>(),
            [],
          ),
          update: (context, auth, previous) {
            previous!.updateAuthProvider(auth);
            return previous;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (context) => GoalProvider(
            context.read<AuthProvider>(),
            [],
          ),
          update: (context, auth, previous) {
            previous!.updateAuthProvider(auth);
            return previous;
          },
        ),

        // 3. (أخيراً) Provider يعتمد على Task, Note, Goal
        //    لازم ييجي *بعدهم*
        ChangeNotifierProvider(
          create: (context) => AiAssistantProvider(
            context.read<TaskProvider>(),
            context.read<NoteProvider>(),
            context.read<GoalProvider>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Wateera',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(
              Brightness.light,
              themeProvider.primaryColor,
            ),
            darkTheme: AppTheme.getTheme(
              Brightness.dark,
              themeProvider.primaryColor,
            ),
            themeMode: themeProvider.themeMode,
            home: const AnimatedSplashScreen(),
          );
        },
      ),
    );
  }
}

Future<void> _requestExactAlarmPermission() async {
  // For Android 12 (API 31) and above, we need to request this permission
  // For Android 14 (API 34) and above, it must be requested at runtime.
  // This permission doesn't have a "permanently denied" state.
  // `request()` will open the settings screen for the user.
  if (await Permission.scheduleExactAlarm.isDenied) {
    final status = await Permission.scheduleExactAlarm.request();
    if (status.isDenied) {
      // The user returned from the settings screen without granting the permission.
      // We can open it again or show a dialog explaining why it's needed.
      // For simplicity, we'll just try to open it one more time.
      _openExactAlarmSettings();
    }
  }
}

void _openExactAlarmSettings() {
  const intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  intent.launch();
}