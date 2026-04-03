import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/entities/task_list.dart';

class TaskBoardState {
  const TaskBoardState({
    required this.isLoading,
    required this.lists,
    required this.tasks,
    required this.selectedListId,
    required this.filter,
    required this.searchQuery,
    required this.selectedTag,
    required this.expandedParentIds,
    required this.errorMessage,
  });

  factory TaskBoardState.initial() {
    return const TaskBoardState(
      isLoading: true,
      lists: [],
      tasks: [],
      selectedListId: null,
      filter: TaskFilter.all,
      searchQuery: '',
      selectedTag: null,
      expandedParentIds: {},
      errorMessage: null,
    );
  }

  final bool isLoading;
  final List<TaskList> lists;
  final List<Task> tasks;
  final String? selectedListId;
  final TaskFilter filter;
  final String searchQuery;
  final String? selectedTag;
  final Set<String> expandedParentIds;
  final String? errorMessage;

  TaskBoardState copyWith({
    bool? isLoading,
    List<TaskList>? lists,
    List<Task>? tasks,
    String? selectedListId,
    bool clearSelectedListId = false,
    TaskFilter? filter,
    String? searchQuery,
    String? selectedTag,
    bool clearSelectedTag = false,
    Set<String>? expandedParentIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskBoardState(
      isLoading: isLoading ?? this.isLoading,
      lists: lists ?? this.lists,
      tasks: tasks ?? this.tasks,
      selectedListId: clearSelectedListId ? null : (selectedListId ?? this.selectedListId),
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: clearSelectedTag ? null : (selectedTag ?? this.selectedTag),
      expandedParentIds: expandedParentIds ?? this.expandedParentIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

