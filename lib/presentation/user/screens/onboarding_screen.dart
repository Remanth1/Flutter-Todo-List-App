import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_notifier.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  String _selectedEmoji = '🙂';
  int _dailyGoal = 5;

  final List<String> _avatarEmojis = ['🙂', '😎', '🚀', '🎯', '⚡', '🔥', '💎', '🌟'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool _isIdentityPageValid() {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    return fullName.length >= 2 &&
        username.length >= 3 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  void _nextPage() {
    if (_currentPage == 3) {
      _submitOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    final notifier = ref.read(userProvider.notifier);
    await notifier.createNewProfile(
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      avatarEmoji: _selectedEmoji,
      dailyGoal: _dailyGoal,
    );

    if (mounted) {
      context.go('/home');
    }
  }

  String _getMotivationalText() {
    return switch (_dailyGoal) {
      1 || 2 || 3 => 'Easy start. Building the habit.',
      4 || 5 || 6 || 7 => 'Solid. You\'ve got this.',
      8 || 9 || 10 || 11 || 12 => 'Ambitious. We love it.',
      _ => 'Beast mode. Let\'s go.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(),
                  _buildIdentityPage(),
                  _buildDailyGoalPage(),
                  _buildAllSetPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: _currentPage == index ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Stay organized. Get things done.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton(
              onPressed: () {
                Future.delayed(const Duration(seconds: 1), _nextPage);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Let\'s get started'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityPage() {
    final isValid = _isIdentityPageValid();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person_outline),
              hintText: 'John Doe',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.alternate_email),
              hintText: 'johndoe',
              helperText: 'Alphanumeric and underscore only',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Text(
            'Pick your avatar',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final emoji in _avatarEmojis)
                GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 56,
                    height: 56,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: isValid ? _nextPage : null,
            child: const Text('Next'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDailyGoalPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'How many tasks per day?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              '$_dailyGoal',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _dailyGoal > 1 ? () => setState(() => _dailyGoal--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 32,
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: _dailyGoal < 20 ? () => setState(() => _dailyGoal++) : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getMotivationalText(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: _nextPage,
            child: const Text('Next'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAllSetPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'You\'re all set, ${_fullNameController.text.split(' ').first}!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '@${_usernameController.text}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_dailyGoal tasks/day',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: _submitOnboarding,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start using Tasks'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

