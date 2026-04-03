import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';

class TaskItemTile extends StatelessWidget {
  const TaskItemTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    this.hasSubtasks = false,
    this.isExpanded = false,
    this.onToggleExpanded,
    this.onAddSubtask,
    this.indent = 0,
  });

  final Task task;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onTap;
  final bool hasSubtasks;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onAddSubtask;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final titleStyle = textStyle?.copyWith(
      color: task.isCompleted
          ? Theme.of(context).textTheme.bodySmall?.color
          : Theme.of(context).textTheme.bodyLarge?.color,
      decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
    );

    Color priorityColor() {
      return switch (task.priority) {
        TaskPriority.high => const Color(0xFFDB4437),
        TaskPriority.medium => const Color(0xFFF9AB00),
        TaskPriority.low => const Color(0xFF34A853),
      };
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12 + indent, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onToggleComplete(value ?? false),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (task.isPinned)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.push_pin, size: 14, color: colorScheme.primary),
                        ),
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: priorityColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(child: Text(task.title, style: titleStyle)),
                    ],
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatDueDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.outline
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final tag in task.tags.take(3))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onAddSubtask != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onAddSubtask,
                tooltip: 'Add subtask',
                icon: const Icon(Icons.add, size: 20),
              ),
            if (hasSubtasks)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onToggleExpanded,
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                tooltip: isExpanded ? 'Collapse subtasks' : 'Expand subtasks',
              ),
          ],
        ),
      ),
    );
  }
}

