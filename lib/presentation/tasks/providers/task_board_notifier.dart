import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/entities/task_list.dart';
import 'app_preferences_notifier.dart';
import 'task_board_state.dart';

final taskBoardNotifierProvider =
    AsyncNotifierProvider<TaskBoardNotifier, TaskBoardState>(
  TaskBoardNotifier.new,
);

class TaskBoardNotifier extends AsyncNotifier<TaskBoardState> {
  @override
  Future<TaskBoardState> build() async {
    await ref.read(notificationServiceProvider).initialize();
    return _loadState(base: TaskBoardState.initial());
  }

  TaskBoardState get _current => state.value ?? TaskBoardState.initial();

  Future<TaskBoardState> _loadState({
    required TaskBoardState base,
    String? selectedListId,
  }) async {
    try {
      final lists = await ref.read(getTaskListsUseCaseProvider).call();
      final activeListId = selectedListId ?? base.selectedListId ?? lists.first.id;
      final tasks = await ref.read(getTasksForListUseCaseProvider).call(activeListId);
      final normalized = await _autoArchiveCompletedTasks(tasks);

      return base.copyWith(
        isLoading: false,
        lists: lists,
        selectedListId: activeListId,
        tasks: normalized,
        clearError: true,
      );
    } catch (_) {
      return base.copyWith(
        isLoading: false,
        errorMessage: 'Could not load tasks.',
      );
    }
  }

  Future<void> _reload() async {
    final current = _current;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _loadState(
        base: current.copyWith(isLoading: true, clearError: true),
        selectedListId: current.selectedListId,
      ),
    );
  }

  Future<List<Task>> _autoArchiveCompletedTasks(List<Task> tasks) async {
    final archiveAfterDays = ref.read(appPreferencesProvider).archiveAfterDays;
    final threshold = DateTime.now().subtract(Duration(days: archiveAfterDays));

    final next = <Task>[];
    for (final task in tasks) {
      if (!task.isCompleted || task.archivedAt != null || task.completedAt == null) {
        next.add(task);
        continue;
      }

      if (task.completedAt!.isBefore(threshold)) {
        final archived = task.copyWith(archivedAt: DateTime.now());
        await ref.read(saveTaskUseCaseProvider).call(archived);
        next.add(archived);
      } else {
        next.add(task);
      }
    }

    return next;
  }

  Future<void> selectList(String listId) async {
    final current = _current.copyWith(selectedListId: listId);
    state = AsyncData(current);
    await _reload();
  }

  Future<void> createList(String title) async {
    if (title.trim().isEmpty) {
      return;
    }
    await ref.read(createTaskListUseCaseProvider).call(title.trim());
    await _reload();
  }

  void setFilter(TaskFilter filter) {
    state = AsyncData(_current.copyWith(filter: filter));
  }

  void setSearchQuery(String query) {
    state = AsyncData(_current.copyWith(searchQuery: query));
  }

  void setSelectedTag(String? tag) {
    if (tag == null || tag.isEmpty) {
      state = AsyncData(_current.copyWith(clearSelectedTag: true));
      return;
    }
    state = AsyncData(_current.copyWith(selectedTag: tag));
  }

  void toggleExpanded(String parentTaskId) {
    final updated = {..._current.expandedParentIds};
    if (updated.contains(parentTaskId)) {
      updated.remove(parentTaskId);
    } else {
      updated.add(parentTaskId);
    }
    state = AsyncData(_current.copyWith(expandedParentIds: updated));
  }

  Future<void> addTask({
    required String title,
    String? parentTaskId,
  }) async {
    final current = _current;
    final listId = current.selectedListId;
    if (listId == null || title.trim().isEmpty) {
      return;
    }

    final siblings = parentTaskId == null
        ? topLevelTasks
        : subtasksByParentId[parentTaskId] ?? <Task>[];

    final task = Task(
      id: '',
      title: title.trim(),
      description: null,
      dueDate: null,
      isCompleted: false,
      listId: listId,
      parentTaskId: parentTaskId,
      orderIndex: siblings.length,
      createdAt: DateTime.now(),
    );

    await ref.read(saveTaskUseCaseProvider).call(task);
    await _reload();

    if (parentTaskId != null) {
      final updated = {..._current.expandedParentIds, parentTaskId};
      state = AsyncData(_current.copyWith(expandedParentIds: updated));
    }
  }

  Future<void> saveTask(Task task) async {
    if (task.title.trim().isEmpty) {
      return;
    }

    final saved = await ref.read(saveTaskUseCaseProvider).call(task);
    if (saved.reminderMinutesBefore != null && saved.dueDate != null && !saved.isCompleted) {
      await ref.read(notificationServiceProvider).scheduleForTask(saved);
    } else {
      await ref.read(notificationServiceProvider).cancelForTask(saved.id);
    }

    await _reload();
  }

  Future<void> toggleTaskComplete(Task task, bool value) async {
    final completedTask = task.copyWith(
      isCompleted: value,
      completedAt: value ? DateTime.now() : null,
      clearCompletedAt: !value,
      clearArchivedAt: !value,
    );
    await saveTask(completedTask);

    if (value && !task.isCompleted && task.recurrence != TaskRecurrence.none) {
      await _createRecurringInstance(completedTask);
    }
  }

  Future<void> _createRecurringInstance(Task completedTask) async {
    final nextDue = _nextDueDate(
      completedTask.dueDate,
      completedTask.recurrence,
      completedTask.customRecurrenceDays,
    );
    if (nextDue == null) {
      return;
    }

    final siblings = topLevelTasks;
    final nextTask = completedTask.copyWith(
      id: '',
      isCompleted: false,
      dueDate: nextDue,
      orderIndex: siblings.length,
      completedAt: null,
      clearCompletedAt: true,
      archivedAt: null,
      clearArchivedAt: true,
    );

    await ref.read(saveTaskUseCaseProvider).call(nextTask);
    await _reload();
  }

  DateTime? _nextDueDate(
    DateTime? dueDate,
    TaskRecurrence recurrence,
    int? customRecurrenceDays,
  ) {
    if (dueDate == null) {
      return null;
    }

    return switch (recurrence) {
      TaskRecurrence.none => null,
      TaskRecurrence.daily => dueDate.add(const Duration(days: 1)),
      TaskRecurrence.weekly => dueDate.add(const Duration(days: 7)),
      TaskRecurrence.custom => dueDate.add(Duration(days: customRecurrenceDays ?? 1)),
    };
  }

  Future<void> deleteTask(String taskId) async {
    await ref.read(notificationServiceProvider).cancelForTask(taskId);
    await ref.read(deleteTaskUseCaseProvider).call(taskId);
    await _reload();
  }

  Future<void> reorderTopLevelTasks(int oldIndex, int newIndex) async {
    final listId = _current.selectedListId;
    if (listId == null) {
      return;
    }

    final ordered = [...topLevelTasks];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, item);

    await ref.read(reorderTasksUseCaseProvider).reorderTopLevel(
          listId: listId,
          orderedTaskIds: ordered.map((t) => t.id).toList(),
        );
    await _reload();
  }

  Future<void> reorderSubtasks(
    String parentTaskId,
    int oldIndex,
    int newIndex,
  ) async {
    final subtasks = [...(subtasksByParentId[parentTaskId] ?? const <Task>[])];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = subtasks.removeAt(oldIndex);
    subtasks.insert(newIndex, item);

    await ref.read(reorderTasksUseCaseProvider).reorderSubtasks(
          parentTaskId: parentTaskId,
          orderedSubtaskIds: subtasks.map((t) => t.id).toList(),
        );
    await _reload();
  }

  List<Task> get _filteredTasks {
    final current = _current;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));
    final query = current.searchQuery.trim().toLowerCase();
    final selectedTag = current.selectedTag;

    bool matchesFilter(Task task) {
      final dueDate = task.dueDate;
      final normalizedDueDate =
          dueDate == null ? null : DateTime(dueDate.year, dueDate.month, dueDate.day);

      switch (current.filter) {
        case TaskFilter.all:
          return task.archivedAt == null;
        case TaskFilter.today:
          return task.archivedAt == null && normalizedDueDate == todayDate;
        case TaskFilter.tomorrow:
          return task.archivedAt == null && normalizedDueDate == tomorrowDate;
        case TaskFilter.upcoming:
          return task.archivedAt == null &&
              normalizedDueDate != null &&
              normalizedDueDate.isAfter(todayDate);
        case TaskFilter.overdue:
          return task.archivedAt == null &&
              !task.isCompleted &&
              normalizedDueDate != null &&
              normalizedDueDate.isBefore(todayDate);
        case TaskFilter.completed:
          return task.archivedAt == null && task.isCompleted;
        case TaskFilter.archived:
          return task.archivedAt != null;
      }
    }

    bool matchesSearch(Task task) {
      if (query.isEmpty) {
        return true;
      }
      final inTitle = task.title.toLowerCase().contains(query);
      final inDescription = (task.description ?? '').toLowerCase().contains(query);
      return inTitle || inDescription;
    }

    bool matchesTag(Task task) {
      if (selectedTag == null || selectedTag.isEmpty) {
        return true;
      }
      return task.tags.contains(selectedTag);
    }

    return _current.tasks
        .where((task) => matchesFilter(task) && matchesSearch(task) && matchesTag(task))
        .toList();
  }

  List<Task> get topLevelTasks {
    final filtered = _filteredTasks.where((t) => t.parentTaskId == null).toList();
    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final priorityOrder = {
        TaskPriority.high: 0,
        TaskPriority.medium: 1,
        TaskPriority.low: 2,
      };
      final priorityCompare = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return filtered;
  }

  Map<String, List<Task>> get subtasksByParentId {
    final map = <String, List<Task>>{};
    for (final task in _filteredTasks.where((task) => task.parentTaskId != null)) {
      final parentId = task.parentTaskId!;
      map.putIfAbsent(parentId, () => []);
      map[parentId]!.add(task);
    }

    for (final entry in map.entries) {
      entry.value.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.orderIndex.compareTo(b.orderIndex);
      });
    }

    return map;
  }

  List<String> get availableTags {
    final set = <String>{};
    for (final task in _current.tasks.where((task) => task.archivedAt == null)) {
      set.addAll(task.tags);
    }
    final tags = set.toList()..sort();
    return tags;
  }

  int get visibleTopLevelCount => topLevelTasks.length;

  int get visibleCompletedTopLevelCount =>
      topLevelTasks.where((task) => task.isCompleted).length;

  TaskList? get selectedList {
    final listId = _current.selectedListId;
    if (listId == null) {
      return null;
    }

    for (final list in _current.lists) {
      if (list.id == listId) {
        return list;
      }
    }
    return null;
  }
}

