enum TaskPriority {
  low,
  medium,
  high,
}

enum TaskRecurrence {
  none,
  daily,
  weekly,
  custom,
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.listId,
    required this.parentTaskId,
    required this.orderIndex,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.isPinned = false,
    this.tags = const [],
    this.recurrence = TaskRecurrence.none,
    this.customRecurrenceDays,
    this.reminderMinutesBefore,
    this.completedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final String listId;
  final String? parentTaskId;
  final int orderIndex;
  final DateTime createdAt;
  final TaskPriority priority;
  final bool isPinned;
  final List<String> tags;
  final TaskRecurrence recurrence;
  final int? customRecurrenceDays;
  final int? reminderMinutesBefore;
  final DateTime? completedAt;
  final DateTime? archivedAt;

  bool get isSubtask => parentTaskId != null;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isCompleted,
    String? listId,
    String? parentTaskId,
    bool clearParentTaskId = false,
    int? orderIndex,
    DateTime? createdAt,
    TaskPriority? priority,
    bool? isPinned,
    List<String>? tags,
    TaskRecurrence? recurrence,
    int? customRecurrenceDays,
    bool clearCustomRecurrenceDays = false,
    int? reminderMinutesBefore,
    bool clearReminderMinutesBefore = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      listId: listId ?? this.listId,
      parentTaskId: clearParentTaskId ? null : (parentTaskId ?? this.parentTaskId),
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      recurrence: recurrence ?? this.recurrence,
      customRecurrenceDays: clearCustomRecurrenceDays
          ? null
          : (customRecurrenceDays ?? this.customRecurrenceDays),
      reminderMinutesBefore: clearReminderMinutesBefore
          ? null
          : (reminderMinutesBefore ?? this.reminderMinutesBefore),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }
}

