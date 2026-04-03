import 'package:flutter/material.dart';

import '../../../domain/entities/task.dart';
import 'empty_state_widget.dart';
import 'subtask_tile.dart';
import 'task_item_tile.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.topLevelTasks,
    required this.subtasksByParentId,
    required this.expandedParentIds,
    required this.onToggleComplete,
    required this.onTaskTap,
    required this.onToggleExpanded,
    required this.onAddSubtask,
    required this.onReorderTopLevel,
    required this.onReorderSubtasks,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final List<Task> topLevelTasks;
  final Map<String, List<Task>> subtasksByParentId;
  final Set<String> expandedParentIds;
  final ValueChanged<Task> onToggleComplete;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<String> onAddSubtask;
  final void Function(int oldIndex, int newIndex) onReorderTopLevel;
  final void Function(String parentTaskId, int oldIndex, int newIndex) onReorderSubtasks;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (topLevelTasks.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: topLevelTasks.length,
      onReorder: onReorderTopLevel,
      proxyDecorator: (child, _, animation) {
        final surface = Theme.of(context).colorScheme.surface;
        return AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            return Material(
              elevation: 3,
              color: surface,
              borderRadius: BorderRadius.circular(8),
              child: child,
            );
          },
        );
      },
      itemBuilder: (context, index) {
        final task = topLevelTasks[index];
        final subtasks = subtasksByParentId[task.id] ?? const <Task>[];
        final expanded = expandedParentIds.contains(task.id);

        return Container(
          key: ValueKey('parent-${task.id}'),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TaskItemTile(
                      task: task,
                      hasSubtasks: subtasks.isNotEmpty,
                      isExpanded: expanded,
                      onToggleExpanded: () => onToggleExpanded(task.id),
                      onAddSubtask: () => onAddSubtask(task.id),
                      onToggleComplete: (_) => onToggleComplete(task),
                      onTap: () => onTaskTap(task),
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.drag_indicator, color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ],
              ),
              if (expanded)
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 8),
                  child: _SubtaskSection(
                    parentTaskId: task.id,
                    subtasks: subtasks,
                    onTapTask: onTaskTap,
                    onToggleComplete: onToggleComplete,
                    onReorderSubtasks: onReorderSubtasks,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SubtaskSection extends StatelessWidget {
  const _SubtaskSection({
    required this.parentTaskId,
    required this.subtasks,
    required this.onTapTask,
    required this.onToggleComplete,
    required this.onReorderSubtasks,
  });

  final String parentTaskId;
  final List<Task> subtasks;
  final ValueChanged<Task> onTapTask;
  final ValueChanged<Task> onToggleComplete;
  final void Function(String parentTaskId, int oldIndex, int newIndex) onReorderSubtasks;

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 38, right: 10, top: 2, bottom: 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No subtasks yet',
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subtasks.length,
      onReorder: (oldIndex, newIndex) => onReorderSubtasks(parentTaskId, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final subtask = subtasks[index];
        return Container(
          key: ValueKey('sub-${subtask.id}'),
          margin: const EdgeInsets.only(bottom: 1),
          child: Row(
            children: [
              Expanded(
                child: SubtaskTile(
                  task: subtask,
                  onToggleComplete: (_) => onToggleComplete(subtask),
                  onTap: () => onTapTask(subtask),
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.drag_indicator, size: 18, color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


