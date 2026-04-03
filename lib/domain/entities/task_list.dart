class TaskList {
  const TaskList({
    required this.id,
    required this.title,
    required this.orderIndex,
  });

  final String id;
  final String title;
  final int orderIndex;

  TaskList copyWith({
    String? id,
    String? title,
    int? orderIndex,
  }) {
    return TaskList(
      id: id ?? this.id,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

