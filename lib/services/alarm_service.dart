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

    await AndroidAlarmManager.oneShotAt(
      targetTime,
      alarm.id,
      alarmCallBack,
      alarmClock: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

  } else {
    //  Weekly recurring alarms
    for (Day day in alarm.listOfDays!) {
      DateTime nextTime = _nextDateForWeekday(alarm.alarmTime, day.dayNumber);

      int uniqueId = alarm.id * 10 + day.dayNumber;

      await AndroidAlarmManager.oneShotAt(
        nextTime,
        uniqueId,
        alarmCallBack,
        alarmClock: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }
  }
}