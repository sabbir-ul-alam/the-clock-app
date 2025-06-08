import 'dart:ffi';

class SearchCity {
  final int cityId;
  final String cityName;
  final String cityStateName;
  final String cityCountryName;
  final String cityTimeZone;
  String? cityTimeOffSet;
  final double cityLatitude;
  final double cityLongitude;

  SearchCity({
    required this.cityId,
    required this.cityName,
    required this.cityStateName,
    required this.cityCountryName,
    required this.cityTimeZone,
    required this.cityLatitude,
    required this.cityLongitude,
    this.cityTimeOffSet,
  });

  factory SearchCity.fromMap(Map<String, dynamic> map) {
    try {
      return SearchCity(
          cityId: map['cityId'],
          cityName: map['cityName'],
          cityStateName: map['cityStateName'],
          cityCountryName: map['countryName'],
          cityTimeZone: map['cityTimeZone'],
          cityLatitude: (map['cityLatitude'] as num).toDouble(),
          cityLongitude: (map['cityLongitude'] as num).toDouble());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
