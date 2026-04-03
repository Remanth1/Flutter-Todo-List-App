import '../../domain/entities/task.dart';

class TaskRecord {
  const TaskRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDateMillis,
    required this.isCompleted,
    required this.listId,
    required this.parentTaskId,
    required this.orderIndex,
    required this.createdAtMillis,
    required this.priority,
    required this.isPinned,
    required this.tags,
    required this.recurrence,
    required this.customRecurrenceDays,
    required this.reminderMinutesBefore,
    required this.completedAtMillis,
    required this.archivedAtMillis,
  });

  final String id;
  final String title;
  final String? description;
  final int? dueDateMillis;
  final bool isCompleted;
  final String listId;
  final String? parentTaskId;
  final int orderIndex;
  final int createdAtMillis;
  final String priority;
  final bool isPinned;
  final List<String> tags;
  final String recurrence;
  final int? customRecurrenceDays;
  final int? reminderMinutesBefore;
  final int? completedAtMillis;
  final int? archivedAtMillis;

  factory TaskRecord.fromMap(Map<dynamic, dynamic> map) {
    return TaskRecord(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDateMillis: map['dueDateMillis'] as int?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      listId: map['listId'] as String,
      parentTaskId: map['parentTaskId'] as String?,
      orderIndex: map['orderIndex'] as int? ?? 0,
      createdAtMillis: map['createdAtMillis'] as int? ?? 0,
      priority: (map['priority'] as String?) ?? TaskPriority.medium.name,
      isPinned: map['isPinned'] as bool? ?? false,
      tags: ((map['tags'] as List?) ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      recurrence: (map['recurrence'] as String?) ?? TaskRecurrence.none.name,
      customRecurrenceDays: map['customRecurrenceDays'] as int?,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
      completedAtMillis: map['completedAtMillis'] as int?,
      archivedAtMillis: map['archivedAtMillis'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDateMillis': dueDateMillis,
      'isCompleted': isCompleted,
      'listId': listId,
      'parentTaskId': parentTaskId,
      'orderIndex': orderIndex,
      'createdAtMillis': createdAtMillis,
      'priority': priority,
      'isPinned': isPinned,
      'tags': tags,
      'recurrence': recurrence,
      'customRecurrenceDays': customRecurrenceDays,
      'reminderMinutesBefore': reminderMinutesBefore,
      'completedAtMillis': completedAtMillis,
      'archivedAtMillis': archivedAtMillis,
    };
  }

  factory TaskRecord.fromEntity(Task task) {
    return TaskRecord(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDateMillis: task.dueDate?.millisecondsSinceEpoch,
      isCompleted: task.isCompleted,
      listId: task.listId,
      parentTaskId: task.parentTaskId,
      orderIndex: task.orderIndex,
      createdAtMillis: task.createdAt.millisecondsSinceEpoch,
      priority: task.priority.name,
      isPinned: task.isPinned,
      tags: task.tags,
      recurrence: task.recurrence.name,
      customRecurrenceDays: task.customRecurrenceDays,
      reminderMinutesBefore: task.reminderMinutesBefore,
      completedAtMillis: task.completedAt?.millisecondsSinceEpoch,
      archivedAtMillis: task.archivedAt?.millisecondsSinceEpoch,
    );
  }

  Task toEntity() {
    TaskPriority parsePriority() {
      for (final value in TaskPriority.values) {
        if (value.name == priority) {
          return value;
        }
      }
      return TaskPriority.medium;
    }

    TaskRecurrence parseRecurrence() {
      for (final value in TaskRecurrence.values) {
        if (value.name == recurrence) {
          return value;
        }
      }
      return TaskRecurrence.none;
    }

    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDateMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(dueDateMillis!),
      isCompleted: isCompleted,
      listId: listId,
      parentTaskId: parentTaskId,
      orderIndex: orderIndex,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      priority: parsePriority(),
      isPinned: isPinned,
      tags: tags,
      recurrence: parseRecurrence(),
      customRecurrenceDays: customRecurrenceDays,
      reminderMinutesBefore: reminderMinutesBefore,
      completedAt: completedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAtMillis!),
      archivedAt: archivedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(archivedAtMillis!),
    );
  }

  TaskRecord copyWith({
    int? orderIndex,
  }) {
    return TaskRecord(
      id: id,
      title: title,
      description: description,
      dueDateMillis: dueDateMillis,
      isCompleted: isCompleted,
      listId: listId,
      parentTaskId: parentTaskId,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAtMillis: createdAtMillis,
      priority: priority,
      isPinned: isPinned,
      tags: tags,
      recurrence: recurrence,
      customRecurrenceDays: customRecurrenceDays,
      reminderMinutesBefore: reminderMinutesBefore,
      completedAtMillis: completedAtMillis,
      archivedAtMillis: archivedAtMillis,
    );
  }
}


