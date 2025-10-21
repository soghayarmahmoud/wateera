import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/providers/theme_provider.dart';
import 'package:wateera/screens/login_screen.dart';
import 'package:wateera/screens/signup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildAuthSection(context),
                const Divider(height: 32),
                _buildThemeSection(context),
                const Divider(height: 32),
                _buildSocialMediaSection(context),
              ],
            ),
          ),
          _buildAppVersion(),
        ],
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Join Wateera to save your progress.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Image.asset('assets/images/user_icon.png', height: 24),
          ),
          title: Text(
            '${authProvider.user!.displayName ?? 'Wateera User'} (${authProvider.userPoints} points)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(authProvider.user!.email ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              // Navigate to login screen after sign out
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildThemeSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Primary Color'),
            trailing: CircleAvatar(backgroundColor: themeProvider.primaryColor),
            onTap: () {
              // You can implement a color picker dialog here
              // For simplicity, we'll cycle through a few colors.
              final List<Color> colors = [
                Colors.purple,
                Colors.blue,
                Colors.teal,
                Colors.orange,
                Colors.red,
              ];
              final currentIndex = colors.indexWhere(
                (c) => c.value == themeProvider.primaryColor.value,
              );
              final nextIndex = (currentIndex + 1) % colors.length;
              themeProvider.setPrimaryColor(colors[nextIndex]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connect with us', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // TODO: Add your actual URLs here
              IconButton(
                icon: const Icon(Icons.code), // Represents GitHub
                onPressed: () => launchUrl(Uri.parse('https://github.com')),
              ),
              IconButton(
                // Using a generic icon for LinkedIn
                icon: const Icon(Icons.business_center),
                onPressed: () => launchUrl(Uri.parse('https://linkedin.com')),
              ),
              IconButton(
                // Using a generic icon for a portfolio or code website
                icon: const Icon(Icons.web),
                onPressed: () =>
                    launchUrl(Uri.parse('https://your-website.com')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        'Wateera v$_appVersion',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
