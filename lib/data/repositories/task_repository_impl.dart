import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_list.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/hive_task_local_data_source.dart';
import '../models/task_list_record.dart';
import '../models/task_record.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._dataSource);

  final HiveTaskLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  @override
  Future<TaskList> createTaskList(String title) async {
    final existing = await getTaskLists();
    final list = TaskList(
      id: _uuid.v4(),
      title: title,
      orderIndex: existing.length,
    );
    await _dataSource.saveTaskList(TaskListRecord.fromEntity(list));
    return list;
  }

  @override
  Future<void> deleteTask(String taskId) {
    return _dataSource.deleteTask(taskId);
  }

  @override
  Future<List<TaskList>> getTaskLists() async {
    var lists = (await _dataSource.getTaskLists()).map((e) => e.toEntity()).toList();

    if (lists.isEmpty) {
      final initial = TaskList(id: 'default', title: 'My Tasks', orderIndex: 0);
      await _dataSource.saveTaskList(TaskListRecord.fromEntity(initial));
      lists = [initial];
    }

    return lists;
  }

  @override
  Future<List<Task>> getTasksByList(String listId) async {
    final tasks = (await _dataSource.getTasksByList(listId)).map((e) => e.toEntity()).toList();

    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.orderIndex.compareTo(b.orderIndex);
    });

    return tasks;
  }

  @override
  Future<void> reorderSubtasks({
    required String parentTaskId,
    required List<String> orderedSubtaskIds,
  }) async {
    final tasks = await _dataSource.getAllTasks();
    final updates = tasks
        .where((task) => task.parentTaskId == parentTaskId)
        .where((task) => orderedSubtaskIds.contains(task.id))
        .toList();

    for (final task in updates) {
      final nextIndex = orderedSubtaskIds.indexOf(task.id);
      await _dataSource.saveTask(task.copyWith(orderIndex: nextIndex));
    }
  }

  @override
  Future<void> reorderTopLevelTasks({
    required String listId,
    required List<String> orderedTaskIds,
  }) async {
    final tasks = await _dataSource.getAllTasks();
    final updates = tasks
        .where((task) => task.listId == listId && task.parentTaskId == null)
        .where((task) => orderedTaskIds.contains(task.id))
        .toList();

    for (final task in updates) {
      final nextIndex = orderedTaskIds.indexOf(task.id);
      await _dataSource.saveTask(task.copyWith(orderIndex: nextIndex));
    }
  }

  @override
  Future<Task> upsertTask(Task task) async {
    final sanitizedTitle = task.title.trim();
    final id = task.id.isEmpty ? _uuid.v4() : task.id;
    final saved = task.copyWith(id: id, title: sanitizedTitle);
    await _dataSource.saveTask(TaskRecord.fromEntity(saved));
    return saved;
  }
}

