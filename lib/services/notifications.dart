import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/tracker.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    final notifGranted =
        await android.requestNotificationsPermission() ?? false;
    final alarmGranted =
        await android.requestExactAlarmsPermission() ?? false;

    return notifGranted && alarmGranted;
  }

  static Future<void> scheduleDailyReminder(Tracker tracker) async {
    if (tracker.reminderTime == null) return;

    final parts = tracker.reminderTime!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: tracker.id.hashCode,
      title: '${tracker.emoji} ${tracker.name}',
      body: 'Hari ke-${tracker.daysElapsed + 1}! Tetap semangat!',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Pengingat Harian',
          channelDescription: 'Pengingat harian untuk tracker',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelReminder(Tracker tracker) async {
    await _plugin.cancel(id: tracker.id.hashCode);
  }

  static Future<void> rescheduleAll(List<Tracker> trackers) async {
    await _plugin.cancelAll();
    for (final t in trackers) {
      await scheduleDailyReminder(t);
    }
  }
}
