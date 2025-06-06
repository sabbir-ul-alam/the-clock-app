
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:theclockapp/models/weather_model.dart';
import 'package:http/http.dart' as http;
class WeatherService{


  final String apiKey = dotenv.env['API_KEY']!;

  Future<WeatherResponse> fetchCurrentWeather(double lat, double long) async{
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey&units=metric"
    );
    final response =  await http.get(url);
    if (response.statusCode == 200){
      return WeatherResponse.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception(("Failed to fetch weather data"));
    }

  }


}