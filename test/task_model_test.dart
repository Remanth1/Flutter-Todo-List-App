import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_app/domain/entities/task.dart';

void main() {
  group('Task Entity', () {
    test('Task creation with all required fields', () {
      final task = Task(
        id: 'task-1',
        title: 'Test Task',
        description: 'A test task',
        dueDate: DateTime(2026, 4, 2),
        isCompleted: false,
        listId: 'list-1',
        parentTaskId: null,
        orderIndex: 0,
        createdAt: DateTime(2026, 4, 2),
      );

      expect(task.id, 'task-1');
      expect(task.title, 'Test Task');
      expect(task.isCompleted, false);
      expect(task.isSubtask, false);
    });

    test('Subtask identification', () {
      final subtask = Task(
        id: 'subtask-1',
        title: 'Subtask',
        description: null,
        dueDate: null,
        isCompleted: false,
        listId: 'list-1',
        parentTaskId: 'task-1',
        orderIndex: 0,
        createdAt: DateTime(2026, 4, 2),
      );

      expect(subtask.isSubtask, true);
      expect(subtask.parentTaskId, 'task-1');
    });

    test('Task copyWith creates new instance with updated fields', () {
      final original = Task(
        id: 'task-1',
        title: 'Original',
        description: null,
        dueDate: null,
        isCompleted: false,
        listId: 'list-1',
        parentTaskId: null,
        orderIndex: 0,
        createdAt: DateTime(2026, 4, 2),
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
      );

      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.id, 'task-1');
      expect(original.title, 'Original');
    });

    test('Task with priority levels', () {
      final task = Task(
        id: 'task-1',
        title: 'High Priority Task',
        description: null,
        dueDate: null,
        isCompleted: false,
        listId: 'list-1',
        parentTaskId: null,
        orderIndex: 0,
        createdAt: DateTime(2026, 4, 2),
        priority: TaskPriority.high,
      );

      expect(task.priority, TaskPriority.high);
    });

    test('Task with recurrence', () {
      final task = Task(
        id: 'task-1',
        title: 'Daily Task',
        description: null,
        dueDate: null,
        isCompleted: false,
        listId: 'list-1',
        parentTaskId: null,
        orderIndex: 0,
        createdAt: DateTime(2026, 4, 2),
        recurrence: TaskRecurrence.daily,
      );

      expect(task.recurrence, TaskRecurrence.daily);
    });
  });
}
