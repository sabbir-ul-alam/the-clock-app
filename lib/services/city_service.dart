import 'package:theclockapp/utils/logger_service.dart';
import '../models/clock_city.dart';
import '../repositories/city_repository.dart';


class CityService{

final CityRepository cityRepository = CityRepository();

int saveClockCity(CityClock city)  {
  try {
    cityRepository.insertCityClock(city);
    return 1;
  }
  catch (exception) {
    LoggerService.error(exception.toString());
    return -1;
  }
}

Future<List<CityClock>> getClockCities() async{
  final clockCities = await cityRepository.getCityClockFromDb();
  return clockCities;
}

}
