
import '../models/city.dart';
import 'package:flutter/material.dart';
import '../services/city_service.dart';
import '../utils/logger_service.dart';
import '../models/clock_city.dart';
import '../services/timezone_service.dart';


class CityClockViewModel extends ChangeNotifier{

  final CityService cityService = CityService();
  final List<CityClock> _clockCitiList = [];
  List<CityClock> get clockCitiList => _clockCitiList;

  void fetchClockCities() async{
    try {
      List<CityClock> clockCities = await cityService.getClockCities();
      _clockCitiList.clear();
      _clockCitiList.addAll(clockCities);
      notifyListeners();
    }
    catch(exception){
      LoggerService.error(exception.toString());
    }
  }

  CityClock convertToClockCity(City city){
    CityClock clockCity = CityClock(
        cityName: city.cityName,
        cityCountryName: city.cityCountryName,
        cityTimeZone: city.cityTimeZone,);
    return clockCity;
    
}

  void addCity (City city){
    try {
      final clockCity = convertToClockCity(city);
      bool saveSuccess = cityService.saveClockCity(clockCity);
      // if (saveSuccess) {
        _clockCitiList.add(clockCity);
        notifyListeners();
      // }
    }
    catch (exception ){
      LoggerService.error(exception.toString());

    }

  }
  String getTime(String timezone){
    return getCurrentTimeForCity(timezone);

  }




}