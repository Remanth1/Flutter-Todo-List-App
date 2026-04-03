import 'package:flutter/material.dart';

import '../../../domain/entities/task_filter.dart';

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('All', TaskFilter.all),
      ('Today', TaskFilter.today),
      ('Tomorrow', TaskFilter.tomorrow),
      ('Upcoming', TaskFilter.upcoming),
      ('Overdue', TaskFilter.overdue),
      ('Completed', TaskFilter.completed),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in chips)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: item.$1,
                selected: selectedFilter == item.$2,
                onTap: () => onFilterChanged(item.$2),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary.withValues(alpha: 0.12) : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

