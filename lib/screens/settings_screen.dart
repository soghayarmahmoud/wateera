
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import 'package:wateera/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WateeraAppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ThemeProvider>(
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
