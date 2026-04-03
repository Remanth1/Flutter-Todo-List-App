import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    try {
      tz_data.initializeTimeZones();
      await _plugin.initialize(settings);
      _isInitialized = true;
    } catch (_) {
      // Notifications are best-effort and should never block core task flows.
      _isInitialized = false;
    }
  }

  Future<void> scheduleForTask(Task task) async {
    if (!_isInitialized || task.dueDate == null || task.reminderMinutesBefore == null) {
      return;
    }

    final reminderAt = task.dueDate!.subtract(
      Duration(minutes: task.reminderMinutesBefore!),
    );
    if (!reminderAt.isAfter(DateTime.now())) {
      return;
    }

    final id = _notificationIdForTask(task.id);
    await cancelForTask(task.id);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders',
        'Task reminders',
        channelDescription: 'Reminders for tasks with due dates',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        task.title,
        'Task reminder',
        tz.TZDateTime.from(reminderAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Ignore scheduling failures to keep task edits instant.
    }
  }

  Future<void> cancelForTask(String taskId) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await _plugin.cancel(_notificationIdForTask(taskId));
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  int _notificationIdForTask(String taskId) {
    return taskId.hashCode & 0x7fffffff;
  }
}


