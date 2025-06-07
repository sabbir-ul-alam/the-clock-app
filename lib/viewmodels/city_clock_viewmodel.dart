import '../models/city.dart';
import 'package:flutter/material.dart';
import '../services/city_service.dart';
import '../utils/logger_service.dart';
import '../models/clock_city.dart';
import '../services/timezone_service.dart';
import '../services/weather_service.dart';

class CityClockViewModel extends ChangeNotifier {
  final CityService cityService = CityService();
  final WeatherService weatherService = WeatherService();
  final List<CityClock> _clockCitiList = [];
  List<CityClock> get clockCitiList => _clockCitiList;

  void fetchClockCities() async {
    try {
      List<CityClock> clockCities = await cityService.getClockCities();
      _clockCitiList.clear();
      _clockCitiList.addAll(clockCities);
      notifyListeners();
    } catch (exception) {
      LoggerService.error(exception.toString());
    }
  }

  CityClock convertToClockCity(City city) {
    CityClock clockCity = CityClock(
        cityName: city.cityName,
        cityStateName: city.cityStateName,
        cityCountryName: city.cityCountryName,
        cityTimeZone: city.cityTimeZone);
    return clockCity;
  }

  void addCity(City city) async {
    try {
      final clockCity = convertToClockCity(city);
      clockCity.weatherData = await weatherService.fetchCurrentWeather(
          city.cityLatitude, city.cityLongitude);
      LoggerService.debug(clockCity.weatherData.toString());

      int saveSuccess = cityService.saveClockCity(clockCity);
      if (saveSuccess == 1) {
        _clockCitiList.add(clockCity);
        notifyListeners();
      }
      else if (saveSuccess == -1)  {
        throw Exception("Failed to save from modelview $saveSuccess");
      }
    } catch (exception) {
      LoggerService.error(exception.toString());
    }
  }

  DateTime getDateTime(String timezone) {
    return getCurrentDateTimeForCity(timezone);
  }
  String getTime(String timezone) {
    return getCurrentTimeForCity(timezone);
  }
}
