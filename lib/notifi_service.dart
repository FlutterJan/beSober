import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    tz.initializeTimeZones();
  }

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
              // Handle notification tapped logic here
              print("Notification Received: id=$id, title=$title, body=$body, payload=$payload");
            });

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      // Handle notification tapped logic here
      print("Notification Tapped: payload=${notificationResponse.payload}");
    });
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId', // Ensure this matches the channel ID used elsewhere
          'channelName',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body,  notificationDetails());
  }

  Future<void> scheduleRandomNotificationDaily({
    String? title,
    String? body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final random = Random();
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 55);

    // Randomize the time within a range (e.g., between 8 AM and 10 AM)
    final int randomHour = 8 + random.nextInt(3);
    final int randomMinute = random.nextInt(60);

    scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10,
      11,
    );

    print('Scheduling notification at $scheduledDate');

    await notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
       notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Ensures it is daily
    );
    print(1);
  }
}
