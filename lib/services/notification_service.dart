import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:isolate';
import 'dart:ui';

import 'package:theclockapp/utils/logger_service.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotificationService() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      LoggerService.debug(
          " ${notificationResponse.actionId.toString()} and id: ${notificationResponse.id}");
      if (notificationResponse.actionId == 'stop_alarm') {
        flutterLocalNotificationsPlugin.cancel(notificationResponse.id!);
      }
      // ...
    }, onDidReceiveBackgroundNotificationResponse: receiveNotificationAction);

    _isInitialized = true;

    // await flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: (response) {
    //     if (response.actionId == 'STOP_ALARM') {
    //       final port = IsolateNameServer.lookupPortByName(
    //         'alarm_command_channel_${response.id}',
    //       );
    //       port?.send('stop_alarm');
    //       flutterLocalNotificationsPlugin.cancel(response.id!);
    //     }
    //   },
    // );

    // _startAlarmEventListener();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'the_clock_app_channel_id',
        'The clock app',
        channelDescription: 'Shows alarms and action button',
        importance: Importance.max,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('stop_alarm', 'Stop', cancelNotification: true),
        ],

      ),
    );
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payload}) async {

    // FlutterRingtonePlayer().play(
    //   android: AndroidSounds.alarm,
    //           ios: IosSounds.alarm,
    //           looping: true,
    //           volume: 1,
    //           asAlarm: true,
    // );



    return flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails());
  }
}

@pragma('vm:entry-point')
void receiveNotificationAction(NotificationResponse notificationResponse) {

  final portName = 'alarm_event_channel';
  // IsolateNameServer.removePortNameMapping(portName);
  final notiIsolate = IsolateNameServer.lookupPortByName(portName);

  LoggerService.debug(
      "Bacground Notification Action Response ${notificationResponse.actionId}");
  if (notificationResponse.actionId == 'stop_alarm') {

    notiIsolate?.send({'type': 'stop_alarm'});
    flutterLocalNotificationsPlugin.cancelAll();




  }
}

//
// void _startAlarmEventListener() {
//   final receivePort = ReceivePort();
//   IsolateNameServer.removePortNameMapping('alarm_event_channel');
//   IsolateNameServer.registerPortWithName(
//       receivePort.sendPort, 'alarm_event_channel');
//
//   receivePort.listen((msg) async {
//     if (msg is Map && msg['type'] == 'alarm_started') {
//       final alarmId = msg['alarmId'];
//       await showAlarmNotification(alarmId);
//     }
//   });
// }
//
// Future<void> showAlarmNotification(int alarmId) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'alarm_channel',
//     'Alarms',
//     channelDescription: 'Channel for alarm notifications',
//     importance: Importance.max,
//     priority: Priority.high,
//     fullScreenIntent: true,
//     playSound: false,
//     actions: <AndroidNotificationAction>[
//       AndroidNotificationAction(
//         'STOP_ALARM',
//         'Stop Alarm',
//         showsUserInterface: true,
//       ),
//     ],
//   );
// }
//
//   const NotificationDetails platformDetails = NotificationDetails(
//     android: androidDetails,
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     alarmId,
//     'Alarm is Ringing!',
//     'Tap Stop to silence',
//     platformDetails,
//   );
// }
