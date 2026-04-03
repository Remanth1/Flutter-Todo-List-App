import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_filter.dart';
import '../../user/providers/user_notifier.dart';
import '../providers/task_board_notifier.dart';
import '../providers/task_board_state.dart';
import '../widgets/add_task_field.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/task_editor_sheet.dart';
import '../widgets/task_list_drawer.dart';
import '../widgets/task_list_view.dart';

class TaskBoardScreen extends ConsumerWidget {
  const TaskBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(taskBoardNotifierProvider);
    final state = asyncState.asData?.value ?? TaskBoardState.initial();
    final notifier = ref.read(taskBoardNotifierProvider.notifier);
    final userProfile = ref.watch(userProvider).profile;
    final emptyCopy = _emptyStateCopyForFilter(state.filter);
    final completed = notifier.visibleCompletedTopLevelCount;
    final total = notifier.visibleTopLevelCount;
    final progress = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(notifier.selectedList?.title ?? 'Tasks'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return GestureDetector(
                onTap: () => context.push('/profile'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      userProfile?.avatarEmoji ?? '🙂',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Stats',
            onPressed: () => context.push('/stats'),
            icon: const Icon(Icons.bar_chart_outlined),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Archived tasks',
            onPressed: () => notifier.setFilter(TaskFilter.archived),
            icon: const Icon(Icons.inventory_2_outlined),
          ),
        ],
      ),
      drawer: TaskListDrawer(
        lists: state.lists,
        selectedListId: state.selectedListId,
        onSelectList: notifier.selectList,
        onCreateList: notifier.createList,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                onChanged: notifier.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search tasks',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FilterTabs(
                selectedFilter: state.filter,
                onFilterChanged: notifier.setFilter,
              ),
            ),
            if (notifier.availableTags.isNotEmpty)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All tags'),
                        selected: state.selectedTag == null,
                        onSelected: (_) => notifier.setSelectedTag(null),
                      ),
                    ),
                    for (final tag in notifier.availableTags)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('#$tag'),
                          selected: state.selectedTag == tag,
                          onSelected: (_) => notifier.setSelectedTag(tag),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '$completed/$total completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: (asyncState.isLoading && asyncState.asData == null)
                  ? const Center(child: CircularProgressIndicator())
                  : TaskListView(
                      topLevelTasks: notifier.topLevelTasks,
                      subtasksByParentId: notifier.subtasksByParentId,
                      expandedParentIds: state.expandedParentIds,
                      onToggleComplete: (task) {
                        notifier.toggleTaskComplete(task, !task.isCompleted);
                      },
                      onTaskTap: (task) => _openEditor(context, notifier, task),
                      onToggleExpanded: notifier.toggleExpanded,
                      onAddSubtask: (parentTaskId) => _openCreateEditor(
                        context,
                        notifier,
                        parentTaskId: parentTaskId,
                      ),
                      onReorderTopLevel: notifier.reorderTopLevelTasks,
                      onReorderSubtasks: notifier.reorderSubtasks,
                      emptyTitle: emptyCopy.$1,
                      emptySubtitle: emptyCopy.$2,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AddTaskField(
          hint: 'Add a task with options',
          onSubmit: (title) => _openCreateEditor(
            context,
            notifier,
            initialTitle: title,
          ),
          onOpenAdvanced: (title) => _openCreateEditor(
            context,
            notifier,
            initialTitle: title,
          ),
        ),
      ),
    );
  }

  void _openCreateEditor(
    BuildContext context,
    TaskBoardNotifier notifier, {
    String initialTitle = '',
    String? parentTaskId,
  }) {
    final listId = notifier.selectedList?.id;
    if (listId == null) {
      return;
    }

    final siblings = parentTaskId == null
        ? notifier.topLevelTasks
        : (notifier.subtasksByParentId[parentTaskId] ?? const <Task>[]);

    final draft = Task(
      id: '',
      title: initialTitle,
      description: null,
      dueDate: null,
      isCompleted: false,
      listId: listId,
      parentTaskId: parentTaskId,
      orderIndex: siblings.length,
      createdAt: DateTime.now(),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return TaskEditorSheet(
          task: draft,
          onSave: notifier.saveTask,
          primaryActionLabel: 'Add',
        );
      },
    );
  }

  void _openEditor(
    BuildContext context,
    TaskBoardNotifier notifier,
    Task task,
  ) {
    final scaffoldContext = context;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return TaskEditorSheet(
          task: task,
          onSave: notifier.saveTask,
          onDelete: () => unawaited(_deleteWithUndo(scaffoldContext, notifier, task)),
        );
      },
    );
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    TaskBoardNotifier notifier,
    Task task,
  ) async {
    final childrenSnapshot = List<Task>.from(
      notifier.subtasksByParentId[task.id] ?? const <Task>[],
    );
    await notifier.deleteTask(task.id);
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Deleted "${task.title}"'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            unawaited(() async {
              await notifier.saveTask(task);
              childrenSnapshot.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
              for (final child in childrenSnapshot) {
                await notifier.saveTask(child);
              }
            }());
          },
        ),
      ),
    );
  }

  (String, String) _emptyStateCopyForFilter(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return ('No tasks yet', 'Add your first task below.');
      case TaskFilter.today:
        return ('Nothing due today', 'Try adding a task with a due date for today.');
      case TaskFilter.tomorrow:
        return ('Nothing due tomorrow', 'Plan tomorrow by assigning tomorrow due dates.');
      case TaskFilter.upcoming:
        return ('No upcoming tasks', 'Tasks due after today will appear here.');
      case TaskFilter.overdue:
        return ('No overdue tasks', 'Great job. You are all caught up.');
      case TaskFilter.completed:
        return ('No completed tasks', 'Completed tasks will show here.');
      case TaskFilter.archived:
        return ('Archive is empty', 'Completed tasks are archived automatically.');
    }
  }
}


