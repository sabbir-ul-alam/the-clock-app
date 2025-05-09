import 'package:hive/hive.dart';
part 'alarm.g.dart';

@HiveType(typeId: 0)
enum Day{
  @HiveField(0)
  sunday(0,'S'),
  @HiveField(1)
  monday(1, 'M'),
  @HiveField(2)
  tuesday(2, 'T'),
  @HiveField(3)
  wednesday(3, 'W'),
  @HiveField(4)
  thursday(4, 'T'),
  @HiveField(5)
  friday(5, 'F'),
  @HiveField(6)
  saturday(6,'S');

  final int dayNumber;
  final String? dayShort;

  const Day(this.dayNumber, this.dayShort);
}


@HiveType(typeId: 1)
class RingTone{
  
  @HiveField(0)
  final String tonePath;
  @HiveField(1)
  final String toneName;
  // @HiveField(2)
  // bool isDefault = true;

  RingTone(
  this.toneName,
  this.tonePath,
  // this.isDefault,
);
}

@HiveType(typeId: 2)
class Alarm extends HiveObject{
  @HiveField(0)
  int id;
  @HiveField(1)
  final String? alarmName;
  @HiveField(2)
  DateTime alarmTime;
  @HiveField(3)
  final RingTone? ringTonePath;
  @HiveField(4)
  int snoozeDuration;
  @HiveField(5)
  List<Day>? listOfDays;
  @HiveField(6)
  bool isAlarm;
  @HiveField(7)
  bool vibration;
  @HiveField(8)
  bool isEnabled;

  Alarm({
    this.id=0,
    this.alarmName,
    required this.alarmTime,
    this.ringTonePath,
    this.snoozeDuration = 5,
    this.listOfDays,
    this.isAlarm = true,
    this.vibration = true,
    this.isEnabled = true,
  });

}
