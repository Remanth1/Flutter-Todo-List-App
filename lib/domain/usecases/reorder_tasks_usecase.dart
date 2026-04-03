import '../repositories/task_repository.dart';

class ReorderTasksUseCase {
  const ReorderTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> reorderTopLevel({
    required String listId,
    required List<String> orderedTaskIds,
  }) {
    return _repository.reorderTopLevelTasks(
      listId: listId,
      orderedTaskIds: orderedTaskIds,
    );
  }

  Future<void> reorderSubtasks({
    required String parentTaskId,
    required List<String> orderedSubtaskIds,
  }) {
    return _repository.reorderSubtasks(
      parentTaskId: parentTaskId,
      orderedSubtaskIds: orderedSubtaskIds,
    );
  }
}

