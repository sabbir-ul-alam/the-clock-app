import 'dart:isolate';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import 'hive_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../utils/logger_service.dart';
import 'notification_service.dart';
import 'dart:ui';


@pragma('vm:entry-point')
void alarmCallBack(int id, Map<String, dynamic> params) async {
  try {
    print("Alarm Isolate: ${Isolate.current.hashCode}");

    final int? alarmId = id;
    final String? tonePath = params['ringTonePath'];
    bool isAlarm = params["isAlarm"];
    bool repeat = params["repeatWeekly"];

    if (alarmId == null) return;


    //attempt to solve the distorted alarm sound at the beginning
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.alarm,
      volume: 0.0,
      asAlarm: true,
      looping: false, // important: don't loop
    );

    // final portName = 'alarm_command_channel_$alarmId';
    // IsolateNameServer.removePortNameMapping(portName);
    // final receivePort = ReceivePort();
    // IsolateNameServer.registerPortWithName(receivePort.sendPort, portName);
    //
    // final mainIsolatePort =
    // IsolateNameServer.lookupPortByName('alarm_event_channel');
    // mainIsolatePort?.send({'type': 'alarm_started', 'alarmId': alarmId});

    if (!isAlarm) {
      Future.delayed(Duration(milliseconds: 300), () {
        FlutterRingtonePlayer().stop();
        FlutterRingtonePlayer().play(
          fromFile: tonePath,
          ios: IosSounds.alarm,
          looping: true,
          volume: 1,
          asAlarm: true,
        );
      });
    } else {
      if(tonePath==null) {
        Future.delayed(Duration(milliseconds: 300), () {
          FlutterRingtonePlayer().stop();
          FlutterRingtonePlayer().play(
            android: AndroidSounds.alarm,
            ios: IosSounds.alarm,
            looping: true,
            volume: 1,
            asAlarm: true,
          );
        });
      }
      else{
        Future.delayed(Duration(milliseconds: 300), () {
          FlutterRingtonePlayer().stop();
          FlutterRingtonePlayer().play(
            fromFile: tonePath,
            ios: IosSounds.alarm,
            looping: true,
            volume: 1,
            asAlarm: true,
          );
        });

      }
    }
    LoggerService.debug("Alarm triggered in the BG ${alarmId}");
    await NotificationService.showNotification("Alarm", "Your alarm is ringing!");

    print("Alarm ID: $alarmId, isAlarm: ${isAlarm}, tonePath: ${tonePath}");

    if(repeat){
      // await initNotificationService();
      final DateTime originalScheduledTime = DateTime.parse(params['scheduledTime']);
      final nextWeek = getNextValidDateTime(originalScheduledTime);
      await AndroidAlarmManager.oneShotAt(
        nextWeek,
        id,
        alarmCallBack,
        alarmClock: true,
        allowWhileIdle: true,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {
          'alarmId': params['alarmId'],
          'ringTonePath': tonePath,
          'isAlarm': isAlarm,
          'repeatWeekly': true,
          'scheduledTime': nextWeek.toIso8601String(),

        },
      );
    }
    // bool stopped = false;
    // await receivePort.timeout(
    //   const Duration(seconds: 60),
    //   onTimeout: (sink) {
    //     print("[Timeout] Auto-stopping alarm.");
    //     FlutterRingtonePlayer().stop();
    //     receivePort.close();
    //     IsolateNameServer.removePortNameMapping(portName);
    //     stopped = true;
    //   },
    // ).forEach((msg) {
    //   if (msg == 'stop_alarm') {
    //     print("[Message] Stop alarm command received.");
    //     FlutterRingtonePlayer().stop();
    //     receivePort.close();
    //     IsolateNameServer.removePortNameMapping(portName);
    //     stopped = true;
    //   }
    //   LoggerService.debug(
    //       "[EXIT] alarmId $alarmId isolate completed, msg $msg port $portName");
    // });
  }catch(e){
    print("Error failed $e");
  }
}


DateTime getNextValidDateTime(DateTime original) {
  final now = DateTime.now();
  while (original.isBefore(now)) {
    // original = original.add(Duration(days: 7));
    //for testing
    original = original.add(Duration(minutes: 2));
  }
  return original;
}

Future<void> setAlarmAt(Alarm newAlarm) async {
  _scheduleAlarmInstances(newAlarm);
}

Future<void> cancelSetAlarm(int baseId, {List<Day>? days}) async {
  if (days == null || days.isEmpty) {
    FlutterRingtonePlayer().stop();
    await AndroidAlarmManager.cancel(baseId);
    LoggerService.debug("One-time alarm cancelled (ID: $baseId)");
  } else {
    for (Day d in days) {
      final recurringId = baseId * 10 + d.dayNumber;
      FlutterRingtonePlayer().stop();
      await AndroidAlarmManager.cancel(recurringId);
      LoggerService.debug("Recurring alarm cancelled (ID: $recurringId)");
    }
  }
}

DateTime _nextDateForWeekday(DateTime alarmTime, int targetDay) {
  if (targetDay == 0) {targetDay = 7;} // for sunday is 7
  // final now = DateTime.now();
  // final today = now.weekday % 7;
  // final diff = (targetDay - today + 7) % 7;
  final today = DateTime.now().weekday;
  DateTime scheduledDay = DateTime.now();
  if(today==targetDay){
    scheduledDay = alarmTime.isBefore(scheduledDay)
        ? scheduledDay.add(Duration(days: 7))
        : scheduledDay;

    // scheduledDay = scheduledDay.add(Duration(days: 7));
  }
  else if(today<targetDay){
    scheduledDay = scheduledDay.add(Duration(days: (targetDay-today)));
  }
  else{
    scheduledDay = scheduledDay.add(Duration(days: (7 +targetDay-today)));
  }
  return DateTime(
    scheduledDay.year,
    scheduledDay.month,
    scheduledDay.day,
    alarmTime.hour,
    alarmTime.minute,
  );
}

Future<void> _scheduleAlarmInstances(Alarm alarm) async {
  if ((alarm.listOfDays?.isEmpty ?? true)) {
    DateTime targetTime = alarm.alarmTime.isBefore(DateTime.now())
        ? alarm.alarmTime.add(Duration(days: 1))
        : alarm.alarmTime;

    LoggerService.debug(targetTime.toString());

    await AndroidAlarmManager.oneShotAt(
      targetTime,
      alarm.id,
      alarmCallBack,
      alarmClock: true,
      allowWhileIdle: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: {
        'alarmId': alarm.id,
        'ringTonePath': alarm.ringTonePath?.tonePath,
        'isAlarm': alarm.isAlarm,
        'repeatWeekly': false,
        'scheduledTime': targetTime.toIso8601String(),

      },
    );
  } else {
    for (Day day in alarm.listOfDays!) {
      DateTime nextTime = _nextDateForWeekday(alarm.alarmTime, day.dayNumber);
      int uniqueId = alarm.id * 10 + day.dayNumber;

      LoggerService.debug(nextTime.toString());

      // LoggerService.debug(nextTime.toIso8601String());

      await AndroidAlarmManager.oneShotAt(
        nextTime,
        uniqueId,
        alarmCallBack,
        alarmClock: true,
        allowWhileIdle: true,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {
          'alarmId': alarm.id,
          'ringTonePath': alarm.ringTonePath?.tonePath,
          'isAlarm': alarm.isAlarm,
          'repeatWeekly': true,
          'scheduledTime': nextTime.toIso8601String(),
        },
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
    byteData.buffer.asUint8List(
        byteData.offsetInBytes, byteData.lengthInBytes),
  );

  return filePath;
}
