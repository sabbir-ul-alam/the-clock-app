import 'package:flutter/material.dart';
import '../viewmodels/city_clock_viewmodel.dart';
import 'dart:async';


class CityClockTab extends StatefulWidget{
  final CityClockViewModel cityClockList;
  const CityClockTab({super.key, required this.cityClockList});

  @override
  CityClockTabState createState() => CityClockTabState();

}

class CityClockTabState extends State<CityClockTab>{
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 30), (Timer t)  => setState((){}));

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: widget.cityClockList,
        builder: (context, child) {
      return ListView.builder(
        itemCount: widget.cityClockList.clockCitiList.length,
        itemBuilder: (context, index) {
          final city = widget.cityClockList.clockCitiList[index];
          final time = widget.cityClockList.getTime(city.cityTimeZone);

          return Container(
            margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
            height: 150,
            decoration: BoxDecoration(
                border: Border.all(
                    color:Colors.grey),
                borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(city.cityCountryName),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                            city.cityName,
                            style: TextStyle(fontSize: 18),
                        ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        time,
                        style: TextStyle(fontSize: 18
                        ),
                      ),
                    ),
                  ],
                ),
                Text(city.weatherData!.weather.main),
                Text(city.weatherData!.weather.description),
                Text(city.weatherData!.main.temperature.toString()),
                Text(city.weatherData!.main.feelsLike.toString()),
                Text(city.weatherData!.main.humidity.toString()),

              ],
            )
          );
        },
      );
    }
    );
  }
}

