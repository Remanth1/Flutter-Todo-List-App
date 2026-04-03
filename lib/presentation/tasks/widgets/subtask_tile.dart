import 'package:flutter/material.dart';

import '../../../domain/entities/task.dart';
import 'task_item_tile.dart';

class SubtaskTile extends StatelessWidget {
  const SubtaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
  });

  final Task task;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TaskItemTile(
      key: key,
      task: task,
      onToggleComplete: onToggleComplete,
      onTap: onTap,
      indent: 22,
    );
  }
}

