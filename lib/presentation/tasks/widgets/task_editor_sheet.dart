import 'package:flutter/material.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    required this.task,
    required this.onSave,
    this.onDelete,
    this.primaryActionLabel,
  });

  final Task task;
  final ValueChanged<Task> onSave;
  final VoidCallback? onDelete;
  final String? primaryActionLabel;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late final TextEditingController _customRecurrenceController;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  int? _customRecurrenceDays;
  int? _reminderMinutesBefore;
  bool _isPinned = false;
  List<String> _tags = const [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _tagsController = TextEditingController();
    _customRecurrenceController = TextEditingController(
      text: widget.task.customRecurrenceDays?.toString() ?? '',
    );
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _recurrence = widget.task.recurrence;
    _customRecurrenceDays = widget.task.customRecurrenceDays;
    _reminderMinutesBefore = widget.task.reminderMinutesBefore;
    _isPinned = widget.task.isPinned;
    _tags = List<String>.from(widget.task.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _customRecurrenceController.dispose();
    super.dispose();
  }

  void _addTag() {
    final raw = _tagsController.text.trim().toLowerCase();
    if (raw.isEmpty || _tags.contains(raw)) {
      return;
    }
    setState(() {
      _tags = [..._tags, raw];
      _tagsController.clear();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.task.id.isEmpty ? 'Add task' : 'Edit task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilterChip(
                  selected: _isPinned,
                  label: const Text('Pinned'),
                  onSelected: (value) => setState(() => _isPinned = value),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(_dueDate == null ? 'Set due date' : formatDueDate(_dueDate!)),
                ),
                if (_dueDate != null)
                  TextButton(
                    onPressed: () => setState(() => _dueDate = null),
                    child: const Text('Clear date'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                      DropdownMenuItem(value: TaskPriority.medium, child: Text('Medium')),
                      DropdownMenuItem(value: TaskPriority.high, child: Text('High')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _reminderMinutesBefore,
                    decoration: const InputDecoration(
                      labelText: 'Reminder',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<int?>(value: null, child: Text('None')),
                      DropdownMenuItem<int?>(value: 10, child: Text('10 min before')),
                      DropdownMenuItem<int?>(value: 60, child: Text('1 hour before')),
                    ],
                    onChanged: (value) => setState(() => _reminderMinutesBefore = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskRecurrence>(
                    initialValue: _recurrence,
                    decoration: const InputDecoration(
                      labelText: 'Recurrence',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: TaskRecurrence.none, child: Text('None')),
                      DropdownMenuItem(value: TaskRecurrence.daily, child: Text('Daily')),
                      DropdownMenuItem(value: TaskRecurrence.weekly, child: Text('Weekly')),
                      DropdownMenuItem(value: TaskRecurrence.custom, child: Text('Custom')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _recurrence = value;
                        if (_recurrence != TaskRecurrence.custom) {
                          _customRecurrenceDays = null;
                          _customRecurrenceController.clear();
                        }
                      });
                    },
                  ),
                ),
                if (_recurrence == TaskRecurrence.custom) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 118,
                    child: TextField(
                      controller: _customRecurrenceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        setState(() => _customRecurrenceDays = parsed);
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Add tag',
                      hintText: 'work',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add tag',
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tag in _tags)
                    InputChip(
                      label: Text('#$tag'),
                      onDeleted: () {
                        setState(() {
                          _tags = _tags.where((item) => item != tag).toList();
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.onDelete != null)
                  TextButton.icon(
                    onPressed: () {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    final updated = widget.task.copyWith(
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                      dueDate: _dueDate,
                      clearDueDate: _dueDate == null,
                      priority: _priority,
                      isPinned: _isPinned,
                      tags: _tags,
                      recurrence: _recurrence,
                      customRecurrenceDays: _customRecurrenceDays,
                      clearCustomRecurrenceDays:
                          _recurrence != TaskRecurrence.custom || _customRecurrenceDays == null,
                      reminderMinutesBefore: _reminderMinutesBefore,
                      clearReminderMinutesBefore: _reminderMinutesBefore == null,
                    );
                    widget.onSave(updated);
                    Navigator.of(context).pop();
                  },
                  child: Text(widget.primaryActionLabel ?? 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

