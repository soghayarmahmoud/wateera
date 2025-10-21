
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/screens/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Use a listener to navigate when the user changes.
    // This is safer than navigating during the build method.
    authProvider.addListener(() {
      if (authProvider.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Wateera',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                authProvider.signInWithGoogle();
              },
              icon: const Icon(Icons.login), // TODO: Add google logo
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
