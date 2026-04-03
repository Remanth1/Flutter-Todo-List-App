// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../tasks/providers/app_preferences_notifier.dart';
import '../providers/user_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider);
    final userState = ref.watch(userProvider);
    final profile = userState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeText(prefs.themeMode)),
            onTap: () => _showThemeSelector(context),
          ),
          const Divider(height: 1),
          _buildSectionHeader(context, 'Productivity'),
          ListTile(
            title: const Text('Daily Goal'),
            subtitle: Text('${profile?.dailyGoal ?? 5} tasks/day'),
            onTap: () => _showDailyGoalSelector(context),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Auto-archive after'),
            subtitle: Text('${prefs.archiveAfterDays} days'),
            onTap: () => _showArchiveSelector(context),
          ),
          const Divider(height: 1),
          _buildSectionHeader(context, 'Notifications'),
          ListTile(
            title: const Text('Reminder defaults'),
            subtitle: const Text('Set default reminder times'),
            onTap: () => _showReminderSelector(context),
          ),
          const Divider(height: 1),
          _buildSectionHeader(context, 'About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System default',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  Future<void> _showThemeSelector(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System default'),
              value: ThemeMode.system,
              groupValue: ref.read(appPreferencesProvider).themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(appPreferencesProvider.notifier).setThemeMode(mode);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: ref.read(appPreferencesProvider).themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(appPreferencesProvider.notifier).setThemeMode(mode);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: ref.read(appPreferencesProvider).themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(appPreferencesProvider.notifier).setThemeMode(mode);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDailyGoalSelector(BuildContext context) async {
    int? selected = ref.read(userProvider).profile?.dailyGoal ?? 5;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Daily Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selected',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: selected!.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                label: '$selected',
                onChanged: (value) {
                  setState(() => selected = value.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(userProvider.notifier).updateProfile(dailyGoal: selected);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showArchiveSelector(BuildContext context) async {
    final options = [3, 7, 14, 30];
    int selected = ref.read(appPreferencesProvider).archiveAfterDays;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-archive completed tasks after'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              RadioListTile<int>(
                title: Text('$option days'),
                value: option,
                groupValue: selected,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(appPreferencesProvider.notifier).setArchiveAfterDays(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReminderSelector(BuildContext context) async {
    const options = ['None', '10 min before', '1 hour before', '1 day before'];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: 'None',
                onChanged: (value) {
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

