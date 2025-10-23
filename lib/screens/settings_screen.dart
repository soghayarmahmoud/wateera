import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/providers/theme_provider.dart';
import 'package:wateera/providers/user_provider.dart';
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
                _buildXPSection(context),
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
            child: Image.asset(
              'assets/images/user.jpg',
              height: 24,
            ), // This was already correct, but I'll ensure it stays.
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

  Widget _buildXPSection(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);

    if (userProvider.currentUser == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.stars,
                size: 48,
                color: theme.primaryColor.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to track your progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Earn XP by completing tasks, goals, notes, and Pomodoro sessions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress & Achievements', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Level and XP Display
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.stars, color: Colors.white, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Level ${userProvider.currentLevel}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userProvider.levelTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total XP',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${userProvider.currentXP}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Progress to Level ${userProvider.currentLevel + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: userProvider.levelProgress,
                            backgroundColor: theme.primaryColor.withOpacity(
                              0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${userProvider.currentUser?.xpInCurrentLevel ?? 0} XP',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '${userProvider.currentUser?.xpForNextLevel ?? 100} XP',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // XP Sources
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to earn XP:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildXPSourceItem(
                        Icons.note_add,
                        'Add a note',
                        '10 XP',
                        Colors.blue,
                        theme,
                      ),
                      _buildXPSourceItem(
                        Icons.task_alt,
                        'Complete a task',
                        '25 XP',
                        Colors.green,
                        theme,
                      ),
                      _buildXPSourceItem(
                        Icons.flag,
                        'Complete a goal',
                        '50 XP',
                        Colors.orange,
                        theme,
                      ),
                      _buildXPSourceItem(
                        Icons.timer,
                        'Finish Pomodoro session',
                        '15 XP',
                        Colors.purple,
                        theme,
                      ),
                      _buildXPSourceItem(
                        Icons.login,
                        'Daily login',
                        '5 XP',
                        Colors.teal,
                        theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXPSourceItem(
    IconData icon,
    String title,
    String xp,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
          Text(
            xp,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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

                  Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
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
                onPressed: () => launchUrl(Uri.parse('https://github.com/soghayarmahmoud')),
              ),
              IconButton(
                // Using a generic icon for LinkedIn
                icon: const Icon(Icons.business_center),
                onPressed: () => launchUrl(Uri.parse('https://www.linkedin.com/in/mahmoud-el-soghayar-1847a5234/')),
              ),
              IconButton(
                // Using a generic icon for a portfolio or code website
                icon: const Icon(Icons.web),
                onPressed: () =>
                    launchUrl(Uri.parse('https://m-el-soghayar.vercel.app/')),
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
