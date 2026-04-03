import '../../domain/entities/task_list.dart';

class TaskListRecord {
  const TaskListRecord({
    required this.id,
    required this.title,
    required this.orderIndex,
  });

  final String id;
  final String title;
  final int orderIndex;

  factory TaskListRecord.fromMap(Map<dynamic, dynamic> map) {
    return TaskListRecord(
      id: map['id'] as String,
      title: map['title'] as String,
      orderIndex: map['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'orderIndex': orderIndex,
    };
  }

  factory TaskListRecord.fromEntity(TaskList list) {
    return TaskListRecord(
      id: list.id,
      title: list.title,
      orderIndex: list.orderIndex,
    );
  }

  TaskList toEntity() {
    return TaskList(id: id, title: title, orderIndex: orderIndex);
  }
}

