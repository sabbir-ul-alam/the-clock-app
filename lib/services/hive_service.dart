import 'dart:io';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:theclockapp/models/alarm.dart';
import 'package:path_provider/path_provider.dart';


// Future<void> initHive() async{
//   await Hive.initFlutter();
//   Hive.registerAdapter(AlarmAdapter());
//   Hive.registerAdapter(DayAdapter());
//   Hive.registerAdapter(RingToneAdapter());
// }


Future<void> initHive() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Get the path to store Hive files
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    // Initialize Hive with the path
    Hive.init(appDocPath);// or Hive.init(...) in isolates
    print("Hive initialized");
  } catch (e) {
    print("Hive already initialized: $e");
  }

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DayAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RingToneAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(AlarmAdapter());
  }
}
