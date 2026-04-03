import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task.dart';
import '../../tasks/providers/task_board_notifier.dart';

class StatsData {
  const StatsData({
    required this.totalCompleted,
    required this.totalActive,
    required this.currentStreak,
    required this.bestStreak,
    required this.last7DayCounts,
    required this.byPriority,
    required this.completionRate,
    required this.overdueCount,
  });

  final int totalCompleted;
  final int totalActive;
  final int currentStreak;
  final int bestStreak;
  final List<int> last7DayCounts;
  final Map<String, int> byPriority;
  final double completionRate;
  final int overdueCount;

  int get totalTasks => totalCompleted + totalActive;
}

final statsProvider = Provider<StatsData>((ref) {
  final asyncState = ref.watch(taskBoardNotifierProvider);
  final allTasks = asyncState.asData?.value.tasks ?? [];

  // Count completed vs active
  final completed = allTasks.where((t) => t.isCompleted).toList();
  final active = allTasks.where((t) => !t.isCompleted).toList();

  // Completion rate
  final total = allTasks.length;
  final completionRate = total == 0 ? 0.0 : completed.length / total;

  // Overdue count
  final now = DateTime.now();
  final overdue = active.where((t) => t.dueDate != null && t.dueDate!.isBefore(now)).length;

  // By priority
  final byPriority = <String, int>{
    'high': allTasks.where((t) => t.priority == TaskPriority.high).length,
    'medium': allTasks.where((t) => t.priority == TaskPriority.medium).length,
    'low': allTasks.where((t) => t.priority == TaskPriority.low).length,
  };

  // Streak calculation - consecutive days with at least 1 completed task
  int currentStreak = 0;
  int bestStreak = 0;
  int tempStreak = 0;

  for (int i = 0; i <= 365; i++) {
    final checkDate = DateTime.now().subtract(Duration(days: i));
    final dateStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final tasksCompletedThatDay = completed.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.isAfter(dateStart) && t.completedAt!.isBefore(dateEnd);
    }).length;

    if (tasksCompletedThatDay > 0) {
      tempStreak++;
      if (i == 0) {
        currentStreak = tempStreak;
      }
    } else {
      if (tempStreak > bestStreak) {
        bestStreak = tempStreak;
      }
      tempStreak = 0;
    }

    if (i == 0 && tasksCompletedThatDay == 0) {
      currentStreak = 0;
    }
  }

  if (tempStreak > bestStreak) {
    bestStreak = tempStreak;
  }

  // Last 7 days counts
  final last7DayCounts = <int>[];
  for (int i = 6; i >= 0; i--) {
    final checkDate = DateTime.now().subtract(Duration(days: i));
    final dateStart = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final count = completed.where((t) {
      if (t.completedAt == null) return false;
      return t.completedAt!.isAfter(dateStart) && t.completedAt!.isBefore(dateEnd);
    }).length;

    last7DayCounts.add(count);
  }

  return StatsData(
    totalCompleted: completed.length,
    totalActive: active.length,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    last7DayCounts: last7DayCounts,
    byPriority: byPriority,
    completionRate: completionRate,
    overdueCount: overdue,
  );
});

