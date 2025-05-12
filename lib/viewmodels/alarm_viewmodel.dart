
import 'package:theclockapp/utils/logger_service.dart';

import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';


class AlarmViewmodel extends ChangeNotifier{
  // Static instance
  static final AlarmViewmodel _instance = AlarmViewmodel._internal();

  // Private constructor
  AlarmViewmodel._internal();

  // Factory constructor returns the same instance
  factory AlarmViewmodel() {
    return _instance;
  }


  late final AlarmRepository _alarmRepository;

  List<Alarm> listOfAlarm = [];

  Future<void> initHiveRepo() async{
    _alarmRepository = await AlarmRepository.init();
  }

  List<Day> convertToDayEnums (List<bool> selectedDays){

    List<Day> days = [];
    for (int ind=0;ind<7;ind++){
      if(selectedDays[ind]){
        days.add(Day.values[ind]);
      }
    }

    //if no specific days is selected that means all days is selected
    // if (days.isEmpty){
    //   for(int ind = 0;ind<7;ind++){
    //     days.add(Day.values[ind]);
    //   }
    // }

    return days;
  }

  bool containsDay( List<Day> alarmDays, int ind ){
    return alarmDays.contains(Day.values[ind]);
  }

  RingTone getPrayerTone(DateTime time){
    // /final fajrPrayerTonePath = await rootBundle.load('assets/ringtones/fajr.mp3');
    // final otherPrayerTonePath = await rootBundle.load('assets/ringtones/otherPrayer.mp3');
    if(time.hour >=3 && time.hour<=10){
      return RingTone('Fajr','assets/ringtones/fajr.mp3');
    }
    else{
      return RingTone('OtherPrayer', 'assets/ringtones/otherPrayer.mp3');
    }
  }

  RingTone getAlarmTone(){
    //dummy
    RingTone tone = RingTone('dummy', 'dummy');
    return tone;
  }


  void saveNewAlarm(DateTime alarm,  List<bool> selectedDays, bool isAlarm) async{
    //   this.id should be generated on the repo before saving
    //other fields should be update with updateAlarm method
    DateTime alarmTime = alarm;
    RingTone alarmTone = isAlarm? getAlarmTone() : getPrayerTone(alarmTime);
    List<Day> days = convertToDayEnums(selectedDays);
    Alarm newAlarm = Alarm(
      alarmTime: alarmTime,
        ringTonePath: alarmTone, listOfDays: days, isAlarm: isAlarm);
    final int id = await _alarmRepository.addAlarm(newAlarm);
    newAlarm.id = id;
    listOfAlarm.add(newAlarm);
    notifyListeners();


    await setAlarmAt(newAlarm);


    LoggerService.debug(alarm.toString());

  }

  void updateAlarm(Alarm newAlarm, {List<Day>? oldDays}) async{
    // _alarmRepository.updateAlarmWithIndex(newAlarm.id, newAlarm);
    // fetchAllAlarms();
    //
    // if(newAlarm.isEnabled) {
    //   await cancelSetAlarm(newAlarm.id);
    //   await setAlarmAt(newAlarm);
    // }
    // else if(!newAlarm.isEnabled){
    //   await cancelSetAlarm(newAlarm.id);
    // }
    _alarmRepository.updateAlarmWithIndex(newAlarm.id, newAlarm);
    fetchAllAlarms();

    if (newAlarm.isEnabled) {
      await cancelSetAlarm(newAlarm.id, days: oldDays ?? []);
      await setAlarmAt(newAlarm);
    } else {
      await cancelSetAlarm(newAlarm.id, days: oldDays ?? []);
    }

    // notifyListeners();

  }
  
  void fetchAllAlarms() {
    listOfAlarm.clear();
    listOfAlarm.addAll(_alarmRepository.getAlarms());
    notifyListeners();
    
  }
}