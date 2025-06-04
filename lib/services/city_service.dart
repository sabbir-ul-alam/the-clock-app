import 'package:theclockapp/utils/logger_service.dart';
import '../models/clock_city.dart';
import '../repositories/city_repository.dart';


class CityService{

final CityRepository cityRepository = CityRepository();

bool saveClockCity(CityClock city) {
  try {
    final id = cityRepository.insertCity(city);
    return true;
  }
  catch (exception) {
    LoggerService.error(exception.toString());
    return false;
  }
}

Future<List<CityClock>> getClockCities() async{
  final clockCities = await cityRepository.getCityClockFromDb();
  return clockCities;
}

}
