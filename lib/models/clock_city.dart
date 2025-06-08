import 'weather_model.dart';


class CityClock {
  int? id;
  int searchCityId;
  String cityName;
  String cityStateName;
  String cityCountryName;
  String? cityTime;
  String? cityDate;
  String cityTimeZone;
  int? citySortingIndex;
  WeatherResponse? weatherData;


  CityClock({
    this.id,
    required this.searchCityId,
    required this.cityName,
    required this.cityCountryName,
    required this.cityStateName,
    this.cityTime,
    this.cityDate,
    required this.cityTimeZone,
    this.citySortingIndex,
    this.weatherData
  });

  factory CityClock.fromMap(Map<String,dynamic> map){
    return CityClock(
      id: map['id'],
      searchCityId: (map['searchCityId'] as num).toInt(),
      cityName: map['cityName'],
      cityStateName: map['cityStateName'],
      cityCountryName: map['cityCountryName'],
      cityTimeZone: map['cityTimeZone'],
      // citySortingIndex: map['city_index']
    );
  }

  Map<String, dynamic>toMap(){
    return{
      'id': id,
      'search_city_id':  searchCityId,
      'city_name': cityName,
      'city_country_name': cityCountryName,
      'city_state_name': cityStateName,
      'city_timezone':cityTimeZone,
      // 'city_index': citySortingIndex,
    };

  }
}


