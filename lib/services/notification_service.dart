import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:isolate';
import 'dart:ui';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
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
        final port = IsolateNameServer.lookupPortByName(
          'alarm_command_channel_${response.id}',
        );
        port?.send('stop_alarm');
        flutterLocalNotificationsPlugin.cancel(response.id!);
      }
    },
  );

  _startAlarmEventListener();
}

void _startAlarmEventListener() {
  final receivePort = ReceivePort();
  IsolateNameServer.removePortNameMapping('alarm_event_channel');
  IsolateNameServer.registerPortWithName(
      receivePort.sendPort, 'alarm_event_channel');

  receivePort.listen((msg) async {
    if (msg is Map && msg['type'] == 'alarm_started') {
      final alarmId = msg['alarmId'];
      await showAlarmNotification(alarmId);
    }
  });
}

Future<void> showAlarmNotification(int alarmId) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarms',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    playSound: false,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'STOP_ALARM',
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
  );
}
