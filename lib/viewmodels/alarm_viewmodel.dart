
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import 'package:flutter/material.dart';

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
    if (days.isEmpty){
      for(int ind = 0;ind<7;ind++){
        days.add(Day.values[ind]);
      }
    }

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


  void saveNewAlarm(DateTime alarm,  List<bool> selectedDays, bool isAlarm) {
    //   this.id should be generated on the repo before saving
    //other fields should be update with updateAlarm method
    DateTime alarmTime = alarm;
    RingTone alarmTone = isAlarm?getAlarmTone():getPrayerTone(alarmTime);
    List<Day> days = convertToDayEnums(selectedDays);
    Alarm newAlarm = Alarm(
      alarmTime: alarmTime, ringTonePath: alarmTone, listOfDays: days, isAlarm: isAlarm);
    _alarmRepository.addAlarm(newAlarm);
    listOfAlarm.add(newAlarm);
    notifyListeners();

  }

  void updateAlam(Alarm newAlarm){
    _alarmRepository.updateAlarmWithIndex(newAlarm.id, newAlarm);
    fetchAllAlarms();
    // notifyListeners();

  }
  
  void fetchAllAlarms() {
    listOfAlarm.clear();
    listOfAlarm.addAll(_alarmRepository.getAlarms());
    notifyListeners();
    
  }





}