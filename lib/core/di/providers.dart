import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/notification_service.dart';
import '../../data/datasources/hive_task_local_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/create_task_list_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_task_lists_usecase.dart';
import '../../domain/usecases/get_tasks_for_list_usecase.dart';
import '../../domain/usecases/reorder_tasks_usecase.dart';
import '../../domain/usecases/save_task_usecase.dart';

// ─── Hive box providers ──────────────────────────────────────────────────────

final tasksBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('tasksBoxProvider must be overridden in main()');
});

final taskListsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('taskListsBoxProvider must be overridden in main()');
});

final settingsBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('settingsBoxProvider must be overridden in main()');
});

final usersBoxProvider = Provider<Box<dynamic>>((ref) {
  throw UnimplementedError('usersBoxProvider must be overridden in main()');
});

// ─── Service providers ────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ─── Repository providers ─────────────────────────────────────────────────────

final localDataSourceProvider = Provider<HiveTaskLocalDataSource>((ref) {
  return HiveTaskLocalDataSource(
    tasksBox: ref.watch(tasksBoxProvider),
    taskListsBox: ref.watch(taskListsBoxProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(localDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(usersBoxProvider));
});

// ─── Use case providers ───────────────────────────────────────────────────────

final getTaskListsUseCaseProvider = Provider<GetTaskListsUseCase>((ref) {
  return GetTaskListsUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskListUseCaseProvider = Provider<CreateTaskListUseCase>((ref) {
  return CreateTaskListUseCase(ref.watch(taskRepositoryProvider));
});

final getTasksForListUseCaseProvider = Provider<GetTasksForListUseCase>((ref) {
  return GetTasksForListUseCase(ref.watch(taskRepositoryProvider));
});

final saveTaskUseCaseProvider = Provider<SaveTaskUseCase>((ref) {
  return SaveTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final reorderTasksUseCaseProvider = Provider<ReorderTasksUseCase>((ref) {
  return ReorderTasksUseCase(ref.watch(taskRepositoryProvider));
});
