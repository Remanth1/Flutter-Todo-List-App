import 'package:intl/intl.dart';

String formatDueDate(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dueDate.year, dueDate.month, dueDate.day);

  if (target == today) {
    return 'Today';
  }

  if (target == today.add(const Duration(days: 1))) {
    return 'Tomorrow';
  }

  return DateFormat('EEE, MMM d').format(dueDate);
}

