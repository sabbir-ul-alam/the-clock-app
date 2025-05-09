import 'package:theclockapp/utils/logger_service.dart';
import '../models/city.dart';
import '../models/clock_city.dart';
import 'db_helper.dart';


class CityRepository{
  final String cityTable = 'cities';
  final String stateTable = 'states';
  final String countryTable = 'countries';
  final String cityClock = 'cityclock';
  final DatabaseHelper _dbHelper = DatabaseHelper();


  Future<List<City>> getCities(String cityName) async{
    final db = await _dbHelper.database;
    final List<Map<String,dynamic>> maps = await db.rawQuery(
      "Select c.name as cityName, c.timezone as cityTimeZone, "
          " cn.name as countryName from ${cityTable} as c"
          " join ${countryTable} as cn on c.country_id=cn.id "
          "where c.name like '${cityName}%' limit 5 ;");
    return List.generate(maps.length, (index) => City.fromMap(maps[index]));

  }

  Future<int> insertCity(ClockCity clockCity) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert(cityClock, clockCity.toMap());
      return id;
    }
    catch (exception) {
      LoggerService.error(exception.toString());
      return -1;
    }
  }

  Future<List<ClockCity>> getClockCitiesFromDb() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
          "Select city_name as cityName, city_country_name as cityCountryName, "
              "city_timezone as cityTimeZone from cityclock;"
      );
      return List.generate(
          maps.length, (index) => ClockCity.fromMap(maps[index]));
    }
    catch(exception){
      LoggerService.error(exception.toString());
      throw();
    }
  }







}