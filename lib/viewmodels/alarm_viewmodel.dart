
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


  void saveNewAlarm(DateTime alarm,  List<bool> selectedDays, bool isAlarm, {RingTone? tone}) async{
    //   this.id should be generated on the repo before saving
    //other fields should be update with updateAlarm method
    DateTime alarmTime = alarm;
    RingTone? alarmTone = isAlarm? tone : await getPrayerTone(alarmTime);
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

  void updateAlarm(Alarm newAlarm, {List<Day>? oldDays} ) async{



    _alarmRepository.updateAlarmWithIndex(newAlarm.id, newAlarm);
    fetchAllAlarms();

    if (newAlarm.isEnabled) {
      LoggerService.debug("Old day list ${oldDays.toString()}");
      await cancelSetAlarm(newAlarm.id, days: oldDays ?? []);
      await setAlarmAt(newAlarm);
    } else {
      final rDay = (newAlarm.listOfDays != null)
          ? List<Day>.from(newAlarm.listOfDays!.cast<Day>())
          : <Day>[];
      LoggerService.debug("Old day list ${rDay.toString()}");
      await cancelSetAlarm(newAlarm.id, days: rDay ?? []);
    }

    // notifyListeners();

  }

  void deleteAlarm(Alarm alarm){
    // _alarmRepository.deleteAlarmWithIndex(alarm.id);
    _alarmRepository.deleteAlarm(alarm);
    listOfAlarm.remove(alarm);
    notifyListeners();

  }
  
  void fetchAllAlarms() {
    listOfAlarm.clear();
    listOfAlarm.addAll(_alarmRepository.getAlarms());
    notifyListeners();
    
  }
}