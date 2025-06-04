import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/logger_service.dart';

class DatabaseHelper{

  static final DatabaseHelper _dbHelperInstance = DatabaseHelper._internal();
  factory DatabaseHelper() => _dbHelperInstance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async{
    if(_database!=null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,'world.sqlite3');
    final exists =await databaseExists(path);

    if(!exists){
      try{
        await Directory(dirname(path)).create(recursive: true);
        final ByteData data = await rootBundle.load('assets/databases/world.sqlite3');
        final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      }
      catch(e){
        LoggerService.error(e.toString());
      }
    }

    return await openDatabase(
      path,
      version: 1,
    );
}


}
