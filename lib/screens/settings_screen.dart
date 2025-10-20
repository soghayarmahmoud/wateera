
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/providers/theme_provider.dart';
import 'package:wateera/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WateeraAppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                if (user != null) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            child: user.photoURL == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(user.email ?? 'No Email'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          authProvider.signOut();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text('Login'),
                  );
                }
              },
            ),
            const Divider(height: 40),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Primary Color', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _buildColorOption(context, themeProvider, const Color(0xFF8B5CF6)),
                        _buildColorOption(context, themeProvider, Colors.blue),
                        _buildColorOption(context, themeProvider, Colors.green),
                        _buildColorOption(context, themeProvider, Colors.orange),
                        _buildColorOption(context, themeProvider, Colors.pink),
                      ],
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, ThemeProvider themeProvider, Color color) {
    return GestureDetector(
      onTap: () => themeProvider.setPrimaryColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: themeProvider.primaryColor == color ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}
