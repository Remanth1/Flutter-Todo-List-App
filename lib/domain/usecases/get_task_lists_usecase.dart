import '../entities/task_list.dart';
import '../repositories/task_repository.dart';

class GetTaskListsUseCase {
  const GetTaskListsUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<TaskList>> call() {
    return _repository.getTaskLists();
  }
}

