class WeatherResponse {
  final Weather weather;
  final MainWeather main;
  final DateTime? timeStamp;

  WeatherResponse({required this.weather, required this.main, this.timeStamp});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      weather: Weather.fromJson(json['weather'][0]),
      main: MainWeather.fromJson(json['main']),
      // timeStamp: json['timeStamp'],
    );
  }

  // Optional, in case you want to serialize the full response to DB
  Map<String, dynamic> toMap() {
    return {
      ...weather.toMap(),
      ...main.toMap(),
      'timeStamp': DateTime.now().millisecondsSinceEpoch,

    };
  }

  factory WeatherResponse.fromMap(Map<String, dynamic> map) {
    return WeatherResponse(
      weather: Weather.fromMap(map),
      main: MainWeather.fromMap(map),
      timeStamp: DateTime.fromMillisecondsSinceEpoch(map['timeStamp']),
    );
  }
}

class Weather {
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weatherMain': main,
      'weatherDescription': description,
      'weatherIcon': icon,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      main: map['weatherMain'],
      description: map['weatherDescription'],
      icon: map['weatherIcon'],
    );
  }
}

class MainWeather {
  final double temperature;
  final double feelsLike;
  final double humidity;

  MainWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
  });

  factory MainWeather.fromJson(Map<String, dynamic> json) {
    return MainWeather(
      // temp: (json['temp'] as num).toDouble(),
      // feelsLike: (json['feels_like'] as num).toDouble(),
      temperature: json['temp'],
      feelsLike: json['feels_like'],
      humidity: json['humidity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mainTemp': temperature,
      'mainFeelsLike': feelsLike,
      'mainHumidity': humidity,
    };
  }

  factory MainWeather.fromMap(Map<String, dynamic> map) {
    return MainWeather(
      // temp: (map['mainTemp'] as num).toDouble(),
      // feelsLike: (map['mainFeelsLike'] as num).toDouble(),
      temperature: map['mainTemp'],
      feelsLike: map['mainFeelsLike'],
      humidity: map['mainHumidity'],
    );
  }
}
