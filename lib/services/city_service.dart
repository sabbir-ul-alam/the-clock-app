import 'package:theclockapp/services/weather_service.dart';
import 'package:theclockapp/utils/logger_service.dart';
import '../models/clock_city.dart';
import '../repositories/city_repository.dart';


class CityService{

final CityRepository cityRepository = CityRepository();
final WeatherService weatherService = WeatherService();


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
  for (var clockCity in clockCities) {
    if (shouldCallApi(clockCity.weatherData!.timeStamp)){
      final city = await cityRepository.getCityById(clockCity.searchCityId);
      clockCity.weatherData = await weatherService.fetchCurrentWeather(city.cityLatitude,city.cityLongitude);
      LoggerService.debug("weather Api called for ${clockCity.cityName}");
    }
  }
  return clockCities;
}
bool shouldCallApi(DateTime? oldTime){

  final diffInMilliSec = DateTime.now().millisecondsSinceEpoch -  oldTime!.millisecondsSinceEpoch;
  final diffInSec = diffInMilliSec/1000;
  //6hour
  if(diffInSec >= 21600){
    return true;
  }
  else {
    return false;
  }


}





}
