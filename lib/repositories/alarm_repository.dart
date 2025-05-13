import 'package:hive/hive.dart';
import '../models/alarm.dart';


class AlarmRepository{
  // static const _lastIdKey = 'last_alarm_id'; // Key to store the last ID
  final Box _settingsBox;
  final Box<Alarm> _alarmBox;

  static Future<AlarmRepository> init() async {
    final alarmBox = await Hive.openBox<Alarm>('alarms');
    final settingsBox = await Hive.openBox('alarm_settings');
    print("[AlarmRepository] alarmBox keys: ${alarmBox.keys}");
    return AlarmRepository._internal(alarmBox, settingsBox);
  }

  AlarmRepository._internal(this._alarmBox, this._settingsBox);

  int _getNextId() {
    final lastId = _settingsBox.get('last_id', defaultValue: 0) as int;
    final nextId = lastId + 1;
    _settingsBox.put('last_id', nextId);
    return lastId;
  }



  Future<int> addAlarm(Alarm alarm) async{
    final id = _getNextId();
    alarm.id = id;
    await _alarmBox.put(id,alarm);
    return alarm.id;
  }

  List<Alarm> getAlarms(){
    return _alarmBox.values.toList();

  }

  Alarm? getAlarmById(int id) {
    return _alarmBox.get(id);
  }

  void updateAlarmWithIndex(int index, Alarm newAlarm){
    _alarmBox.putAt(index, newAlarm);
  }

  // void updateAlam(Alarm newAlarm){
  //   newAlarm.save();
  // }

  void deleteAlarmWithIndex(int index) {
    _alarmBox.deleteAt(index);
  }

  void deleteAlarm(Alarm alarm){
    alarm.delete();
  }



}