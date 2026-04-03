import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/user/screens/app_splash_screen.dart';
import '../../presentation/user/screens/onboarding_screen.dart';
import '../../presentation/user/screens/profile_screen.dart';
import '../../presentation/user/screens/settings_screen.dart';
import '../../presentation/tasks/screens/task_board_screen.dart';
import '../../presentation/stats/screens/stats_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const AppSplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => TaskBoardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (_, __) => const StatsScreen(),
      ),
    ],
  );
});

