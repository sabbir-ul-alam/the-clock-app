import 'package:flutter/material.dart';
import '../models/city.dart';
import '../repositories/city_repository.dart';
import '../utils/logger_service.dart';
import '../services/timezone_service.dart';


class SearchCitiesViewModel extends ChangeNotifier{


  List<SearchCity> searchedCityList = [];
  final CityRepository cityRepository = CityRepository();

  SearchCitiesViewModel();

  void getCitiesFromDbByName(String name) async{
    try {
      List<SearchCity> dbCities = await cityRepository.getCitiesByName(name);

      List<SearchCity> citiesWithOffset = getGmtOffset(dbCities);


      for (final city in citiesWithOffset) {
        searchedCityList.add(city);
      }
      notifyListeners();
    }
    catch (e) {
      LoggerService.error('Error:$e');
    }

  }
  void removeTheCurrentList(){
    searchedCityList.clear();
    notifyListeners();
  }
}