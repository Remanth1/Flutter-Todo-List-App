import '../entities/task_list.dart';
import '../repositories/task_repository.dart';

class CreateTaskListUseCase {
  const CreateTaskListUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskList> call(String title) {
    return _repository.createTaskList(title);
  }
}

