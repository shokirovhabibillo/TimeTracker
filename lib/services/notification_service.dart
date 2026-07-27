import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../data/models/task_model.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(settings);

    const androidChannel = AndroidNotificationChannel(
      'focus_life_tasks',
      'Vazifa eslatmalari',
      description: 'Rejalashtirilgan vazifalar, uyqu va odatlar uchun eslatmalar',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules a single reminder `notificationOffsetMin` minutes before
  /// the task starts. For recurring tasks, `matchDateTimeComponents` is
  /// used so the OS itself repeats the alarm (daily / weekly).
  Future<void> scheduleForTask(TaskModel task) async {
    final fireTime =
        task.startTime.subtract(Duration(minutes: task.notificationOffsetMin));
    if (fireTime.isBefore(DateTime.now()) && !task.isRecurring) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_tasks',
        'Vazifa eslatmalari',
        channelDescription:
            'Rejalashtirilgan vazifalar, uyqu va odatlar uchun eslatmalar',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(_colorFromHex(task.colorCode)),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final scheduledDate = tz.TZDateTime.from(fireTime, tz.local);

    await _plugin.zonedSchedule(
      task.id ?? task.hashCode,
      '${TaskCategory.label(task.category)}: ${task.title}',
      'Boshlanishiga ${task.notificationOffsetMin} daqiqa qoldi',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: task.isRecurring
          ? (task.recurrenceRule == 'DAILY'
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime)
          : null,
    );
  }

  Future<void> cancelForTask(int taskId) => _plugin.cancel(taskId);

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Fired by the analytics engine when distracting-app time exceeds
  /// the planned budget for the day.
  Future<void> showFocusWarning(String message) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_warnings',
        'Diqqat ogohlantirishlari',
        channelDescription: 'Chalg\'ituvchi ilovalarga sarflangan vaqt haqida',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      999999,
      "Diqqatingizni jamlang!",
      message,
      details,
    );
  }

  int _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return int.parse('FF$cleaned', radix: 16);
  }
}
