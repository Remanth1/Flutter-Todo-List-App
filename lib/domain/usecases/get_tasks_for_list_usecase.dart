import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksForListUseCase {
  const GetTasksForListUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call(String listId) {
    return _repository.getTasksByList(listId);
  }
}

