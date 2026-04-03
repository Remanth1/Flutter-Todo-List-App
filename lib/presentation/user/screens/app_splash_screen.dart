import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_notifier.dart';

/// Splash screen that waits for [UserNotifier] to finish its async profile
/// load, then navigates to onboarding or home exactly once.
///
/// Because [UserNotifier.build] now starts an async _loadProfile() call and
/// begins with isLoaded=false, we watch the provider and navigate as soon as
/// isLoaded flips to true — this works correctly for both the initial build
/// and any subsequent state changes.
class AppSplashScreen extends ConsumerStatefulWidget {
  const AppSplashScreen({super.key});

  @override
  ConsumerState<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends ConsumerState<AppSplashScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    if (userState.isLoaded && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (userState.profile == null) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
