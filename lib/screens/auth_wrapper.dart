
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/screens/login_screen.dart';
import 'package:wateera/screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
