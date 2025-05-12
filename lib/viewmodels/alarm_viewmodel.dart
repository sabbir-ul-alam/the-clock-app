
import 'package:theclockapp/utils/logger_service.dart';

import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import 'package:flutter/material.dart';
import '../services/alarm_service.dart';



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

  Future<RingTone> getPrayerTone(DateTime time) async{


      if(time.hour >=3 && time.hour<=10){
        final copiedTonePath = await copyAssetToFile('assets/ringtones/fajr.mp3',
            'fajr.mp3');
        return RingTone('fajrPrayer', copiedTonePath);
      }
    else{
        final copiedTonePath = await copyAssetToFile('assets/ringtones/otherPrayer.mp3',
            'otherPrayer.mp3');
        return RingTone('otherPrayer', copiedTonePath); // now this is a real file path

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
    RingTone alarmTone = isAlarm? getAlarmTone() : await getPrayerTone(alarmTime);
    List<Day> days = convertToDayEnums(selectedDays);
    Alarm newAlarm = Alarm(
      alarmTime: alarmTime,
        ringTonePath: alarmTone, listOfDays: days, isAlarm: isAlarm);
    final int id = await _alarmRepository.addAlarm(newAlarm);
    newAlarm.id = id;
    listOfAlarm.add(newAlarm);
    notifyListeners();

    await setAlarmAt(newAlarm);


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