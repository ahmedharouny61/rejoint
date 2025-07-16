import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> scheduleDailyNotification(String title, String body) async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

  final notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: 'Daily reminders for exercises',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  final now = tz.TZDateTime.now(tz.local);
  final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10)
      .isBefore(now)
      ? tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 10)
      : tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);

  await _notification.zonedSchedule(
    1,
    title,
    body,
    scheduledDate,
    notificationDetails,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}


  
}
