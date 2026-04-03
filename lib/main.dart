import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/hive_boxes.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/tasks/providers/app_preferences_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    await Hive.initFlutter();
  }

  final tasksBox = await Hive.openBox<dynamic>(HiveBoxes.tasks);
  final listsBox = await Hive.openBox<dynamic>(HiveBoxes.taskLists);
  final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.settings);
  final usersBox = await Hive.openBox<dynamic>(HiveBoxes.users);

  runApp(
    ProviderScope(
      overrides: [
        tasksBoxProvider.overrideWithValue(tasksBox),
        taskListsBoxProvider.overrideWithValue(listsBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
        usersBoxProvider.overrideWithValue(usersBox),
      ],
      child: const TasksApp(),
    ),
  );
}

class TasksApp extends ConsumerWidget {
  const TasksApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Tasks',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkAppTheme(),
      themeMode: prefs.themeMode,
      routerConfig: router,
    );
  }
}


