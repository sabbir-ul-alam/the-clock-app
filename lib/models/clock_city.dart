
class ClockCity {
  String cityName;
  String cityCountryName;
  String? cityTime;
  String? cityDate;
  String cityTimeZone;
  int? citySortingIndex;
  String? cityTemperature;




  ClockCity({
    required this.cityName,
    required this.cityCountryName,
    this.cityTime,
    this.cityTemperature,
    this.cityDate,
    required this.cityTimeZone,
    this.citySortingIndex
  });

  factory ClockCity.fromMap(Map<String,dynamic> map){
    return ClockCity(
      cityName: map['cityName'],
      // cityStateName: map['cityStateName'],
      cityCountryName: map['cityCountryName'],
      cityTimeZone: map['cityTimeZone'],
      // citySortingIndex: map['city_index']
    );
  }

  Map<String, dynamic>toMap(){
    return{
      'city_name': cityName,
      'city_country_name': cityCountryName,
      'city_timezone':cityTimeZone,
      // 'city_index': citySortingIndex,
    };

  }
}


