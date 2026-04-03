import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_list_record.dart';
import '../models/task_record.dart';

class HiveTaskLocalDataSource {
  const HiveTaskLocalDataSource({
    required Box<dynamic> tasksBox,
    required Box<dynamic> taskListsBox,
  })  : _tasksBox = tasksBox,
        _taskListsBox = taskListsBox;

  final Box<dynamic> _tasksBox;
  final Box<dynamic> _taskListsBox;

  Future<List<TaskRecord>> getTasksByList(String listId) async {
    final records = _tasksBox.values
        .whereType<Map>()
        .map((raw) => TaskRecord.fromMap(raw))
        .where((record) => record.listId == listId)
        .toList();

    return records;
  }

  Future<void> saveTask(TaskRecord record) async {
    await _tasksBox.put(record.id, record.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
    final subtasks = _tasksBox.values
        .whereType<Map>()
        .map((raw) => TaskRecord.fromMap(raw))
        .where((task) => task.parentTaskId == taskId)
        .toList();

    for (final subtask in subtasks) {
      await _tasksBox.delete(subtask.id);
    }
  }

  Future<List<TaskListRecord>> getTaskLists() async {
    final lists = _taskListsBox.values
        .whereType<Map>()
        .map((raw) => TaskListRecord.fromMap(raw))
        .toList();
    lists.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return lists;
  }

  Future<void> saveTaskList(TaskListRecord record) async {
    await _taskListsBox.put(record.id, record.toMap());
  }

  Future<List<TaskRecord>> getAllTasks() async {
    return _tasksBox.values
        .whereType<Map>()
        .map((raw) => TaskRecord.fromMap(raw))
        .toList();
  }
}

