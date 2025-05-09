import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:theclockapp/models/alarm.dart';


Future<void> initHive() async{
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(DayAdapter());
  Hive.registerAdapter(RingToneAdapter());
}