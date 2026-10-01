import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../core/constants.dart';

/// Settings: feedback toggles, appearance, data reset (confirmed), about.
class SettingsScreen extends StatelessWidget {
  final AppServices services;

  const SettingsScreen({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: services.settings,
        builder: (context, _) {
          final s = services.settings;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(context, 'Feedback'),
              SwitchListTile(
                title: const Text('Sound'),
                subtitle: const Text('Tap, move and success sounds'),
                value: s.sound,
                onChanged: s.setSound,
              ),
              SwitchListTile(
                title: const Text('Haptics'),
                subtitle: const Text('Subtle vibration on moves and results'),
                value: s.haptics,
                onChanged: s.setHaptics,
              ),
              _section(context, 'Appearance'),
              SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('A proper dark theme, not inverted'),
                value: s.darkMode,
                onChanged: s.setDarkMode,
              ),
              _section(context, 'General'),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Daily puzzle reminders'),
                value: s.notifications,
                onChanged: s.setNotifications,
              ),
              _section(context, 'Data'),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Reset progress'),
                subtitle: const Text('Clears levels, streaks and statistics'),
                onTap: () => _confirmReset(context),
              ),
              _section(context, 'About'),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About ONE MOVE'),
                onTap: () => _showAbout(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy'),
                onTap: () => _showPrivacy(context),
              ),
              ListTile(
                leading: const Icon(Icons.tag_rounded),
                title: const Text('Version'),
                subtitle: Text(AppConstants.version),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This permanently clears your completed levels, streaks, '
          'hints used and statistics. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await services.progress.resetProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset. Fresh start!')),
        );
      }
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About ONE MOVE'),
        content: const Text(
          'ONE MOVE — One Puzzle. One Move. Think Different.\n\n'
          'Every puzzle is solved with exactly one meaningful move. '
          'The game rewards creative thinking, not fast tapping.\n\n'
          '200 hand-tuned levels, a daily puzzle, and zero accounts: '
          'your progress never leaves your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy'),
        content: const Text(
          'ONE MOVE works fully offline for the core game.\n\n'
          '• No account, no login, no email, no phone number\n'
          '• No location, no contacts, no unnecessary permissions\n'
          '• Progress and settings are stored only on this device\n'
          '• Nothing is uploaded anywhere',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
