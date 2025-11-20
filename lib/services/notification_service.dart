import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);

    // timezone setup
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // fallback to UTC if unknown
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static Future<void> showImmediate(int id, String title, String body) async {
    final android = AndroidNotificationDetails(
      'drink_reminder_channel',
      'Drink Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.max,
      priority: Priority.high,
    );
    final ios = DarwinNotificationDetails();
    final details = NotificationDetails(android: android, iOS: ios);
    await _plugin.show(id, title, body, details);
  }

  static Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    TimeOfDay time, {
    String? soundName,
  }) async {
    // compute next instance in local timezone
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    AndroidNotificationDetails android;
    if (soundName != null && soundName.isNotEmpty) {
      android = AndroidNotificationDetails(
        'drink_reminder_channel',
        'Drink Reminders',
        channelDescription: 'Reminders to drink water',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound(soundName),
      );
    } else {
      android = AndroidNotificationDetails(
        'drink_reminder_channel',
        'Drink Reminders',
        channelDescription: 'Reminders to drink water',
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    final ios = (soundName != null && soundName.isNotEmpty)
        ? DarwinNotificationDetails(sound: soundName)
        : const DarwinNotificationDetails();

    final details = NotificationDetails(android: android, iOS: ios);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);
}
