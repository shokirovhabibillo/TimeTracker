import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../data/models/task_model.dart';
import '../data/motivation_content.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone));
    } catch (_) {
      // If detection fails for any reason, fall back to UTC rather than
      // crashing — notifications will still work, just anchored to UTC.
    }

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
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Low-importance (silent) channel for the persistent running-timer
    // notification — no sound/vibration on each update, just a live
    // on-screen chronometer while a focus session is active.
    const timerChannel = AndroidNotificationChannel(
      'focus_life_timer',
      'Faol taymer',
      description: "Pomodoro/stopwatch ishlayotganda doimiy ko'rsatiladi",
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(timerChannel);
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
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
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
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

  /// A second, separate notification fired at the task's *exact* start
  /// time (not the reminder offset) carrying a category-relevant
  /// motivational tip — "announces" the plan beginning, as opposed to
  /// the earlier heads-up reminder.
  Future<void> scheduleMotivationForTask(TaskModel task) async {
    if (task.startTime.isBefore(DateTime.now()) && !task.isRecurring) return;

    final pool = MotivationLibrary.forTaskCategory(_taskCategoryToMotivationCategory(task.category));
    final tip = pool[task.id.hashCode.abs() % pool.length];

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_tasks',
        'Vazifa eslatmalari',
        channelDescription:
            'Rejalashtirilgan vazifalar, uyqu va odatlar uchun eslatmalar',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        color: Color(_colorFromHex(task.colorCode)),
        styleInformation: BigTextStyleInformation(tip.body),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final scheduledDate = tz.TZDateTime.from(task.startTime, tz.local);

    await _plugin.zonedSchedule(
      _motivationNotificationId(task.id ?? task.hashCode),
      '${TaskCategory.label(task.category)} boshlandi: ${task.title}',
      tip.title,
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

  int _motivationNotificationId(int taskId) => 500000 + taskId.abs() % 400000;

  String? _taskCategoryToMotivationCategory(String taskCategory) {
    switch (taskCategory) {
      case TaskCategory.study:
        return 'study';
      case TaskCategory.work:
        return 'work';
      case TaskCategory.sleep:
        return 'sleep';
      default:
        return null;
    }
  }

  Future<void> cancelMotivationForTask(int taskId) =>
      _plugin.cancel(_motivationNotificationId(taskId));

  /// Shown on the parent's device when the linked child completes a
  /// task — a plain, immediate notification (not scheduled).
  Future<void> showChildActivityUpdate(String taskTitle) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_tasks',
        'Vazifa eslatmalari',
        channelDescription: 'Rejalashtirilgan vazifalar, uyqu va odatlar uchun eslatmalar',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      600000 + taskTitle.hashCode.abs() % 100000,
      "Farzandingiz vazifani bajardi",
      taskTitle,
      details,
    );
  }

  /// Schedules a daily-repeating reminder for one medicine dose time
  /// (e.g. "09:00 every day"). [medicineNotificationId] should be a
  /// unique id per (medicine, dose-slot) pair so multiple doses don't
  /// overwrite each other.
  Future<void> scheduleMedicineReminder({
    required int medicineNotificationId,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_tasks',
        'Vazifa eslatmalari',
        channelDescription: 'Rejalashtirilgan vazifalar, uyqu va odatlar uchun eslatmalar',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      700000 + medicineNotificationId,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelMedicineReminder(int medicineNotificationId) =>
      _plugin.cancel(700000 + medicineNotificationId);

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

  static const int _timerNotificationId = 424242;

  /// Shows (or updates) a persistent, silent notification with a live
  /// on-screen counter — visible on the lock screen and notification
  /// shade even if the app is backgrounded. Uses Android's built-in
  /// chronometer rendering, so the OS itself keeps it ticking; we don't
  /// need to re-post it every second.
  ///
  /// [baseTime] is the reference instant: for a stopwatch counting UP,
  /// pass the moment the session started; for a countdown, pass the
  /// moment it will reach zero and set [countDown] to true.
  Future<void> showRunningTimer({
    required String title,
    required DateTime baseTime,
    bool countDown = false,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_timer',
        'Faol taymer',
        channelDescription: "Pomodoro/stopwatch ishlayotganda doimiy ko'rsatiladi",
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        usesChronometer: true,
        chronometerCountDown: countDown,
        when: baseTime.millisecondsSinceEpoch,
        playSound: false,
        enableVibration: false,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.stopwatch,
      ),
      iOS: const DarwinNotificationDetails(presentSound: false),
    );
    await _plugin.show(_timerNotificationId, title, null, details);
  }

  /// Freezes the notification at a fixed text (e.g. "Pauza qilingan —
  /// 05:23") while the timer is paused — chronometer has no native pause,
  /// so we swap to a plain static notification instead.
  Future<void> showPausedTimer({required String title, required String frozenText}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'focus_life_timer',
        'Faol taymer',
        channelDescription: "Pomodoro/stopwatch ishlayotganda doimiy ko'rsatiladi",
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(presentSound: false),
    );
    await _plugin.show(_timerNotificationId, title, frozenText, details);
  }

  Future<void> cancelTimerNotification() => _plugin.cancel(_timerNotificationId);

  int _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return int.parse('FF$cleaned', radix: 16);
  }
}
