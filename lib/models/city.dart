
class City {
  String cityName;
  // String? cityStateName;
  String cityCountryName;
  String cityTimeZone;
  String? cityTimeOffSet;

  City({
    required this.cityName,
    required this.cityCountryName,
    required this.cityTimeZone,
    this.cityTimeOffSet,
  });
  factory City.fromMap(Map<String,dynamic> map){
    return City(
      cityName: map['cityName'],
      // cityStateName: map['cityStateName'],
      cityCountryName: map['countryName'],
      cityTimeZone: map['cityTimeZone'],
    );
  }
}


