import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/domain/entities/task.dart';
import 'package:todo_list_app/domain/entities/task_filter.dart';
import 'package:todo_list_app/domain/entities/task_list.dart';
import 'package:todo_list_app/presentation/tasks/providers/app_preferences_notifier.dart';
import 'package:todo_list_app/presentation/tasks/providers/task_board_notifier.dart';
import 'package:todo_list_app/presentation/tasks/providers/task_board_state.dart';
import 'package:todo_list_app/presentation/tasks/screens/task_board_screen.dart';

void main() {
  testWidgets('shows filter-specific empty copy for Today', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskBoardNotifierProvider.overrideWith(() {
            return _FakeTaskBoardNotifier(
              const TaskBoardState(
                isLoading: false,
                lists: [TaskList(id: 'list-1', title: 'My Tasks', orderIndex: 0)],
                tasks: [],
                selectedListId: 'list-1',
                filter: TaskFilter.today,
                searchQuery: '',
                selectedTag: null,
                expandedParentIds: {},
                errorMessage: null,
              ),
            );
          }),
          appPreferencesProvider.overrideWith(_FakeAppPreferencesNotifier.new),
        ],
        child: const MaterialApp(home: TaskBoardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing due today'), findsOneWidget);
    expect(find.text('Try adding a task with a due date for today.'), findsOneWidget);
  });

  testWidgets('delete action shows undo snackbar and restores parent + child tasks', (
    WidgetTester tester,
  ) async {
    final parent = Task(
      id: 'parent-1',
      title: 'Parent Task',
      description: null,
      dueDate: null,
      isCompleted: false,
      listId: 'list-1',
      parentTaskId: null,
      orderIndex: 0,
      createdAt: DateTime(2026, 1, 1),
    );
    final child = Task(
      id: 'child-1',
      title: 'Subtask A',
      description: null,
      dueDate: null,
      isCompleted: false,
      listId: 'list-1',
      parentTaskId: 'parent-1',
      orderIndex: 0,
      createdAt: DateTime(2026, 1, 1),
    );

    late _FakeTaskBoardNotifier fakeNotifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskBoardNotifierProvider.overrideWith(() {
            fakeNotifier = _FakeTaskBoardNotifier(
              TaskBoardState(
                isLoading: false,
                lists: const [TaskList(id: 'list-1', title: 'My Tasks', orderIndex: 0)],
                tasks: [parent, child],
                selectedListId: 'list-1',
                filter: TaskFilter.all,
                searchQuery: '',
                selectedTag: null,
                expandedParentIds: const {'parent-1'},
                errorMessage: null,
              ),
            );
            return fakeNotifier;
          }),
          appPreferencesProvider.overrideWith(_FakeAppPreferencesNotifier.new),
        ],
        child: const MaterialApp(home: TaskBoardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Parent Task'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Deleted "Parent Task"'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(fakeNotifier.savedTasks.map((task) => task.id).toList(), ['parent-1', 'child-1']);
  });
}

class _FakeTaskBoardNotifier extends TaskBoardNotifier {
  _FakeTaskBoardNotifier(this._initialState);

  final TaskBoardState _initialState;

  final List<Task> savedTasks = <Task>[];

  @override
  Future<TaskBoardState> build() async => _initialState;

  @override
  Future<void> deleteTask(String taskId) async {
    final current = state.value!;
    state = AsyncData(current.copyWith(
      tasks: current.tasks
          .where((task) => task.id != taskId && task.parentTaskId != taskId)
          .toList(),
    ));
  }

  @override
  Future<void> saveTask(Task task) async {
    savedTasks.add(task);
    final current = state.value!;
    final next = current.tasks.where((existing) => existing.id != task.id).toList();
    next.add(task);
    state = AsyncData(current.copyWith(tasks: next));
  }

  @override
  Future<void> createList(String title) async {}

  @override
  Future<void> addTask({required String title, String? parentTaskId}) async {}

  @override
  Future<void> reorderTopLevelTasks(int oldIndex, int newIndex) async {}

  @override
  Future<void> reorderSubtasks(String parentTaskId, int oldIndex, int newIndex) async {}

  @override
  Future<void> selectList(String listId) async {
    state = AsyncData(state.value!.copyWith(selectedListId: listId));
  }

  @override
  Future<void> toggleTaskComplete(Task task, bool value) async {}
}

class _FakeAppPreferencesNotifier extends AppPreferencesNotifier {
  @override
  AppPreferencesState build() {
    return const AppPreferencesState(
      themeMode: ThemeMode.system,
      archiveAfterDays: 7,
    );
  }
}

