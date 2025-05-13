import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


Future<void> initNotificationService() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      if (response.actionId == 'STOP_ALARM') {
        FlutterRingtonePlayer().stop();
        flutterLocalNotificationsPlugin.cancelAll();
      }
    },
  );

  print("DidReceiveNotification");
}

Future<void>showAlarmNotification(int alarmId) async{

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarms',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: false,
    playSound: false,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'STOP_ALARM', // This must match the ID checked in `onDidReceiveNotificationResponse`
        'Stop Alarm',
        showsUserInterface: true,
      ),
    ],
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    alarmId,
    'Alarm is Ringing!',
    'Tap Stop to silence',
    platformDetails,
    payload: 'alarm_payload',
  );

}