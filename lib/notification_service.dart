import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService =
  NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  //Initialization Settings for iOS devices
  final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );


  Future<bool?> requestIOSPermissions() async {
    return await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  AndroidNotificationDetails _androidNotificationDetails =
  AndroidNotificationDetails(
    'Alarm Test 1',
    'Alarm',
    channelDescription: 'channel description',
    sound: RawResourceAndroidNotificationSound('alarm_slow'),
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  IOSNotificationDetails _iosNotificationDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,

  );





  Future<void> init(void Function(String?)? onSelectNotification) async {

    //Initialization Settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_stat_access_alarm');

    //Initialization Settings for iOS
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification
    );

  }

  Future<void> showNotifications() async {

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: _androidNotificationDetails,
        iOS: _iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification Title',
      'This is the Notification Body',
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }

  Future<void> scheduleNotifications({required tz.TZDateTime scheduledTime}) async {

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: _androidNotificationDetails,
        iOS: _iosNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "Alarm App",
        "Alarm for ${scheduledTime.hour}:${scheduledTime.minute}!",
        scheduledTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }



  Future<bool> get didNotificationLaunchApp async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    print('didNotificationLaunchApp ${notificationAppLaunchDetails?.didNotificationLaunchApp}');
    return notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  }

}