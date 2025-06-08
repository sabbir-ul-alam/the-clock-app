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

  Future<SearchCity> getCityById(int id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery("""
      SELECT 
      cities.id AS cityId,
      cities.name AS cityName,
      states.name AS cityStateName,
      countries.name AS countryName,
      cities.latitude AS cityLatitude,
      cities.longitude AS cityLongitude,
      cities.timezone AS cityTimeZone
      FROM ${cityTable}  cities
      JOIN ${stateTable}  states ON cities.state_id = states.id
      JOIN ${countryTable}  countries ON cities.country_id = countries.id
      WHERE cities.id = ?
        """,[id]);

      return SearchCity.fromMap(maps[0]);

    } catch (e) {
      LoggerService.error(e.toString());
      throw Exception(e);
    }
  }

  Future<List<SearchCity>> getCitiesByName(String cityName) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery("""
      SELECT 
      cities.id AS cityId,
      cities.name AS cityName,
      states.name AS cityStateName,
      countries.name AS countryName,
      cities.latitude AS cityLatitude,
      cities.longitude AS cityLongitude,
      cities.timezone AS cityTimeZone
      FROM ${cityTable}  cities
      JOIN ${stateTable}  states ON cities.state_id = states.id
      JOIN ${countryTable}  countries ON cities.country_id = countries.id
      WHERE cities.name LIKE ? OR states.name LIKE ?
      ORDER BY 
      CASE 
        WHEN cities.name LIKE ? THEN 0
        ELSE 1
      END,
      cityName
      limit 30
      
      """, ['%$cityName%', '%$cityName%', '%$cityName%']);
      return List.generate(
          maps.length, (index) => SearchCity.fromMap(maps[index]));
    } catch (e) {
      LoggerService.error(e.toString());
      return [];
    }
  }

  Future<void> insertWeather(int cityId, WeatherResponse weatherData) async {
    final db = await _dbHelper.database;
    try {
      final weatherMap = weatherData.toMap();
      weatherMap['cityId'] = cityId;
      await db.insert(weatherTable, weatherMap);
    } catch (exception) {
      LoggerService.error(exception.toString());
    }
  }

  Future<int> insertCityClock(CityClock clockCity) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert(cityClockTable, clockCity.toMap());
      if (clockCity.weatherData != null) {
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
      // final List<Map<String, dynamic>> maps = await db.rawQuery(
      // "Select id, city_name as cityName, city_country_name as cityCountryName, "
      // "city_state_name as cityStateName, city_timezone as cityTimeZone from cityclock;");
      final result = await db.rawQuery('''
      select 
      c.id as id,
      c.search_city_id as searchCityId,
      c.city_name as cityName,
      c.city_state_name as cityStateName,
      c.city_country_name as cityCountryName,
      c.city_timezone as cityTimeZone,
      w.mainTemp as mainTemp,
      w.mainFeelsLike as mainFeelsLike,
      w.mainHumidity as mainHumidity ,
      w.weatherMain as weatherMain,
      w.weatherDescription as weatherDescription,
      w.weatherIcon as weatherIcon,
      w.timeStamp as timeStamp
      from ${cityClockTable} c
      JOIN ${weatherTable} w on c.id = w.cityId;
      ''');

      // List<CityClock> cityClockList =
      //     List.generate(maps.length, (index) => CityClock.fromMap(maps[index]));

      return result.map((row) {
        CityClock cityClock = CityClock.fromMap(row);
        WeatherResponse weatherResponse = WeatherResponse.fromMap(row);
        cityClock.weatherData = weatherResponse;
        return cityClock;
      }).toList();
    } catch (exception) {
      LoggerService.error(exception.toString());
      throw ();
    }
  }
}
