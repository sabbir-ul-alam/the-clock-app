import 'package:theclockapp/utils/logger_service.dart';
import '../models/city.dart';
import '../models/clock_city.dart';
import '../models/weather_model.dart';
import 'db_helper.dart';

class CityRepository {
  final String cityTable = 'cities';
  final String stateTable = 'states';
  final String countryTable = 'countries';
  final String cityClockTable = 'cityclock';
  final String weatherTable = 'weather';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<City>> getCities(String cityName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("""
      SELECT 
      cities.name AS cityName,
      states.name AS cityStateName,
      countries.name AS countryName,
      cities.latitude AS cityLatitude,
      cities.longitude AS cityLongitude,
      cities.timezone AS cityTimeZone
      FROM ${cityTable} as cities
      JOIN ${stateTable} as states ON cities.state_id = states.id
      JOIN ${countryTable} as countries ON cities.country_id = countries.id
      WHERE cities.name LIKE ? OR states.name LIKE ?
      ORDER BY 
      CASE 
        WHEN cities.name LIKE ? THEN 0
        ELSE 1
      END,
      city_name
      """,['%$cityName%', '%$cityName%', '%$cityName%']);
    return List.generate(maps.length, (index) => City.fromMap(maps[index]));
  }

  Future<void> insertWeather(int cityId, WeatherResponse weatherData) async {
    final db = await _dbHelper.database;
    try{
      final weatherMap = weatherData.toMap();
      weatherMap['cityId'] = cityId;
      await db.insert(weatherTable, weatherMap);
    }
    catch(exception){
      LoggerService.error(exception.toString());
    }

  }

    Future<int> insertCityClock(CityClock clockCity) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert(cityClockTable, clockCity.toMap());
      if(clockCity.weatherData != null) {
        await insertWeather(id, clockCity.weatherData!);
      }
      return id;
    } catch (exception) {
      LoggerService.error(exception.toString());
      return -1;
    }
  }

  Future<List<CityClock>> getCityClockFromDb() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
          "Select city_name as cityName, city_country_name as cityCountryName, "
          "city_timezone as cityTimeZone from cityclock;");
      return List.generate(
          maps.length, (index) => CityClock.fromMap(maps[index]));
    } catch (exception) {
      LoggerService.error(exception.toString());
      throw ();
    }
  }
}
