import 'dart:isolate';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import 'hive_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../utils/logger_service.dart';
import 'notification_service.dart';



@pragma('vm:entry-point')
void alarmCallBack(int id, Map<String, dynamic> params) async{
  print("Alarm Isolate: ${Isolate.current.hashCode}");
  print("Alarm triggered in the BG");
  final int? alarmId = params['alarmId'];
  if (alarmId == null) return;
  await initHive();
  final AlarmRepository repository = await AlarmRepository.init();
  // Fetch alarm using your repository method
  final Alarm? alarm = repository.getAlarmById(alarmId);
  if (alarm == null) return;
  final String? tonePath = alarm.ringTonePath?.tonePath;

  if (!alarm.isAlarm) {
    FlutterRingtonePlayer().play(
      fromFile: tonePath,
      ios: IosSounds.alarm,
      looping: true,
      volume: 1,
      asAlarm: true,
    );
  }else{
    FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true, // Android only - API >= 28
      volume: 1, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );
  }
  print("Alarm ID: $alarmId, isAlarm: ${alarm.isAlarm}, tonePath: ${alarm.ringTonePath?.tonePath}");
  await showAlarmNotification(alarmId);


}

Future<void> setAlarmAt(Alarm newAlarm) async {
  //if old time is set, then add one day
  // if (newAlarm.alarmTime.isBefore(DateTime.now())) {
  //   newAlarm.alarmTime = newAlarm.alarmTime.add(Duration(days: 1));
  // }
  // await AndroidAlarmManager.oneShotAt(
  //     newAlarm.alarmTime, newAlarm.id, alarmCallBack,
  //     alarmClock: true, wakeup: true, rescheduleOnReboot: true);
  _scheduleAlarmInstances(newAlarm);
}

Future<void> cancelSetAlarm(int baseId, {List<Day>? days}) async {
  // await AndroidAlarmManager.cancel(alarmId);
    if (days == null || days.isEmpty) {
      await AndroidAlarmManager.cancel(baseId);
      print("One-time alarm cancelled (ID: $baseId)");
    } else {
      for (Day d in days) {
        final recurringId = baseId * 10 + d.dayNumber;
        await AndroidAlarmManager.cancel(recurringId);
        print("Recurring alarm cancelled (ID: $recurringId)");
      }
    }
  }

DateTime _nextDateForWeekday(DateTime time, int targetDay) {
  final now = DateTime.now();
  final today = now.weekday % 7; // normalize Sunday = 0
  final diff = (targetDay - today + 7) % 7;

  final scheduledDay = now.add(Duration(days: diff));
  return DateTime(
    scheduledDay.year,
    scheduledDay.month,
    scheduledDay.day,
    time.hour,
    time.minute,
  );
}

Future<void> _scheduleAlarmInstances(Alarm alarm) async {
  if ((alarm.listOfDays?.isEmpty ?? true)) {
    // One-time alarm
    DateTime targetTime = alarm.alarmTime.isBefore(DateTime.now())
        ? alarm.alarmTime.add(Duration(days: 1))
        : alarm.alarmTime;

    LoggerService.debug(targetTime.toString());

    await AndroidAlarmManager.oneShotAt(
      targetTime,
      alarm.id,
      alarmCallBack,
      alarmClock: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {'alarmId': alarm.id},
    );

  } else {
    //  Weekly recurring alarms
    for (Day day in alarm.listOfDays!) {
      DateTime nextTime = _nextDateForWeekday(alarm.alarmTime, day.dayNumber);

      int uniqueId = alarm.id * 10 + day.dayNumber;

      LoggerService.debug(nextTime.toString());


      await AndroidAlarmManager.oneShotAt(
        nextTime,
        uniqueId,
        alarmCallBack,
        alarmClock: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {'alarmId': alarm.id},
      );
    }
  }
}

Future<String> copyAssetToFile(String assetPath, String fileName) async {
  final byteData = await rootBundle.load(assetPath);
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';

  final file = File(filePath);
  await file.writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );

  return filePath;
}