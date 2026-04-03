import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../tasks/providers/task_board_notifier.dart';
import '../providers/user_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _dailyGoalController;
  String _selectedEmoji = '🙂';

  final List<String> _avatarEmojis = ['🙂', '😎', '🚀', '🎯', '⚡', '🔥', '💎', '🌟'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _dailyGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }

  Future<void> _openEditProfileSheet() async {
    final userState = ref.read(userProvider);
    final profile = userState.profile;
    if (profile == null) return;

    _nameController.text = profile.fullName;
    _usernameController.text = profile.username;
    _selectedEmoji = profile.avatarEmoji;
    _dailyGoalController.text = profile.dailyGoal.toString();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildEditProfileSheet(),
    );
  }

  Widget _buildEditProfileSheet() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: '@',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dailyGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Goal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Avatar',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final emoji in _avatarEmojis)
                  GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedEmoji == emoji
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: _selectedEmoji == emoji
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final notifier = ref.read(userProvider.notifier);
                  final dailyGoal = int.tryParse(_dailyGoalController.text) ?? 5;
                  await notifier.updateProfile(
                    fullName: _nameController.text,
                    username: _usernameController.text,
                    avatarEmoji: _selectedEmoji,
                    dailyGoal: dailyGoal.clamp(1, 20),
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearCompletedConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear completed tasks?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final taskState = ref.read(taskBoardNotifierProvider).asData?.value;
      if (taskState != null) {
        final notifier = ref.read(taskBoardNotifierProvider.notifier);
        for (final task in taskState.tasks.where((t) => t.isCompleted)) {
          await notifier.deleteTask(task.id);
        }
      }
    }
  }

  Future<void> _showResetAllConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text('This will delete all tasks and return to onboarding. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userNotifier = ref.read(userProvider.notifier);
      await userNotifier.resetAllData();
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final profile = userState.profile;
    final taskState = ref.watch(taskBoardNotifierProvider).asData?.value;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text(
            'No profile found',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final completedCount = taskState?.tasks.where((t) => t.isCompleted).length ?? 0;
    final totalTasks = taskState?.tasks.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            profile.avatarEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${profile.username}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Member since ${formatJoinDate(profile.joinedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '$completedCount',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Done',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${totalTasks - completedCount}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Active',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${profile.dailyGoal}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Goal/day',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _openEditProfileSheet,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Clear completed tasks'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _showClearCompletedConfirmation,
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.refresh_outlined),
                    title: const Text('Reset all data'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _showResetAllConfirmation,
                    textColor: Theme.of(context).colorScheme.error,
                    iconColor: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatJoinDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${months[date.month - 1]} ${date.year}';
}

