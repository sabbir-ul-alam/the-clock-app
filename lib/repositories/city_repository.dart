import 'package:theclockapp/utils/logger_service.dart';
import '../models/city.dart';
import '../models/clock_city.dart';
import 'db_helper.dart';

class CityRepository {
  final String cityTable = 'cities';
  final String stateTable = 'states';
  final String countryTable = 'countries';
  final String cityClock = 'cityclock';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<City>> getCities(String cityName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("""
      SELECT 
      cities.id,
      cities.name AS city_name,
      states.name AS state_name,
      countries.name AS country_name,
      cities.latitude,
      cities.longitude,
      cities.timezone
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

  Future<int> insertCity(ClockCity clockCity) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert(cityClock, clockCity.toMap());
      return id;
    } catch (exception) {
      LoggerService.error(exception.toString());
      return -1;
    }
  }

  Future<List<ClockCity>> getClockCitiesFromDb() async {
    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
          "Select city_name as cityName, city_country_name as cityCountryName, "
          "city_timezone as cityTimeZone from cityclock;");
      return List.generate(
          maps.length, (index) => ClockCity.fromMap(maps[index]));
    } catch (exception) {
      LoggerService.error(exception.toString());
      throw ();
    }
  }
}
