import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roambook/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: settingsProvider.isDarkMode,
              onChanged: (value) => settingsProvider.toggleDarkMode(),
            ),
          ),
          ListTile(
            title: const Text('Notifications'),
            trailing: Switch(
              value: settingsProvider.isNotificationsEnabled,
              onChanged: (value) => settingsProvider.toggleNotifications(),
            ),
          ),
          ExpansionTile(
            title: const Text('Data & Storage'),
            children: [
              ListTile(
                title: const Text('Clear Cache'),
                onTap: () {
                  // TODO: Implement clear cache functionality
                },
              ),
              ListTile(
                title: const Text('Export Data'),
                onTap: () {
                  // TODO: Implement export functionality
                },
              ),
              ListTile(
                title: const Text('Import Data'),
                onTap: () {
                  // TODO: Implement import functionality
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('About'),
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                onTap: () {
                  // TODO: Navigate to terms of service
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Language'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('English'),
                        onTap: () {
                          settingsProvider.setLanguage('en');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Spanish'),
                        onTap: () {
                          settingsProvider.setLanguage('es');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 