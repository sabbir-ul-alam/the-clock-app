import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/alarm.dart';

@pragma('vm:entry-point')
void alarmCallBack() {
  print("Alarm triggered in the BG");
  FlutterRingtonePlayer().play(
    android: AndroidSounds.notification,
    ios: IosSounds.alarm,
    looping: true, // Android only - API >= 28
    volume: 0.1, // Android only - API >= 28
    asAlarm: true, // Android only - all APIs
  );
}

Future<void> setAlarmAt(Alarm newAlarm) async {

  //if old time is set, then add one day
  if(newAlarm.alarmTime.isBefore(DateTime.now())){
    newAlarm.alarmTime = newAlarm.alarmTime.add(Duration(days: 1));
  }


  await AndroidAlarmManager.oneShotAt(
      newAlarm.alarmTime, newAlarm.id, alarmCallBack,
      alarmClock: true, wakeup: true, rescheduleOnReboot: true);
}

Future<void> cancelSetAlarm(int alarmId) async{

   await AndroidAlarmManager.cancel(alarmId);

}

// Future<void> checkAndRequestExactAlarmPermission() async {
//   if (Platform.isAndroid) {
//     final androidInfo = await DeviceInfoPlugin().androidInfo;
//     final sdkInt = androidInfo.version.sdkInt;
//
//     if (sdkInt >= 31) {
//       // Check if the app can schedule exact alarms
//       var status = await Permission.scheduleExactAlarm.status;
//       if (!status.isGranted) {
//         // Launch system settings
//         // final intent = AndroidIntent(
//         //   action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
//         //   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
//         // );
//         // await intent.launch();
//         await Permission.scheduleExactAlarm.request();
//
//       }
//     }
//   }
// }
