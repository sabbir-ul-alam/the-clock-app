import 'package:theclockapp/utils/logger_service.dart';
import '../models/clock_city.dart';
import '../repositories/city_repository.dart';


class CityService{

final CityRepository cityRepository = CityRepository();

bool saveClockCity(ClockCity city) {
  try {
    final id = cityRepository.insertCity(city);
    return true;
  }
  catch (exception) {
    LoggerService.error(exception.toString());
    return false;
  }
}

Future<List<ClockCity>> getClockCities() async{
  final clockCities = await cityRepository.getClockCitiesFromDb();
  return clockCities;
}

}
