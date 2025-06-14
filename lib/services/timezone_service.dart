import '../models/city.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:intl/intl.dart' as intl;

void initTimeZone(){
  tz.initializeTimeZones();
}

String formatOffSet(SearchCity city){
  try {
    final loc = tz.getLocation(city.cityTimeZone);
    final now = tz.TZDateTime.now(loc);
    final offSet = 'GTM ${now.timeZoneOffset.inHours.toString().padLeft(
        2, '0')}:'
        '${now.timeZoneOffset.inMinutes.remainder(60).abs().toString().padLeft(
        2, '0')}';
    return offSet;
  }
  catch(e){
    throw Exception(e);
  }

}

List<SearchCity> getGmtOffset(List<SearchCity> cities) {
  List<SearchCity> cityListWithOffset = [];
  for (final city in cities) {
    final offset = formatOffSet(city);
    city.cityTimeOffSet = offset;
    cityListWithOffset.add(city);
  }
  return cityListWithOffset;
}



DateTime getCurrentDateTimeForCity(String timeZone) {
  final location = tz.getLocation(timeZone);
  return tz.TZDateTime.now(location);
  // final cityTime = tz.TZDateTime.now(location);
  // return formatTime(cityTime);
}
String getCurrentTimeForCity(String timeZone) {
  final location = tz.getLocation(timeZone);
  // return tz.TZDateTime.now(location);
  final cityTime = tz.TZDateTime.now(location);
  return formatTime(cityTime);
}


String formatTime(DateTime dateTime) {
  final format = intl.DateFormat('hh:mm a'); // Use 'a' for AM/PM
  return format.format(dateTime);
}




