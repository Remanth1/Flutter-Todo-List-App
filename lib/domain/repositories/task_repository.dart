import '../entities/task.dart';
import '../entities/task_list.dart';

abstract class TaskRepository {
  Future<List<TaskList>> getTaskLists();
  Future<TaskList> createTaskList(String title);

  Future<List<Task>> getTasksByList(String listId);
  Future<Task> upsertTask(Task task);
  Future<void> deleteTask(String taskId);

  Future<void> reorderTopLevelTasks({
    required String listId,
    required List<String> orderedTaskIds,
  });

  Future<void> reorderSubtasks({
    required String parentTaskId,
    required List<String> orderedSubtaskIds,
  });
}

