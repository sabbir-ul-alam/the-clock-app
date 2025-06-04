import 'dart:ffi';

class City {
  final String cityName;
  final String cityStateName;
  final String cityCountryName;
  final String cityTimeZone;
  String? cityTimeOffSet;
  final double cityLatitude;
  final double cityLongitude;

  City({
    required this.cityName,
    required this.cityStateName,
    required this.cityCountryName,
    required this.cityTimeZone,
    required this.cityLatitude,
    required this.cityLongitude,
    this.cityTimeOffSet,
  });

  factory City.fromMap(Map<String, dynamic> map) {
    try {
      return City(
          cityName: map['cityName'],
          cityStateName: map['cityStateName'],
          cityCountryName: map['countryName'],
          cityTimeZone: map['cityTimeZone'],
          cityLatitude: (map['cityLatitude'] as num).toDouble(),
          cityLongitude: (map['cityLongitude'] as num).toDouble()
      );
    }
    catch (e) {
      throw Exception(e.toString());
    }
  }
}
