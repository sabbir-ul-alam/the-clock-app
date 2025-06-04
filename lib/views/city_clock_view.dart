import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/city_clock_viewmodel.dart';
import 'dart:async';

class CityClockTab extends StatefulWidget {
  final CityClockViewModel cityClockList;
  const CityClockTab({super.key, required this.cityClockList});

  @override
  CityClockTabState createState() => CityClockTabState();
}

class CityClockTabState extends State<CityClockTab> {
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer =
        Timer.periodic(Duration(seconds: 30), (Timer t) => setState(() {}));
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
                  padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200]
                  ),
                  child: Row(
                    // spacing: 5,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          time,
                          style: TextStyle(color: Colors.black, fontSize: 50, wordSpacing: 5),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.black, // Placeholder divider color
                      ),
                      // const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:CrossAxisAlignment.start,
                          children: [
                            Text(
                              toBeginningOfSentenceCase(city.cityCountryName.trim()),
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            Text(
                              toBeginningOfSentenceCase(city.cityName.trim()),
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      // Text(city.weatherData!.weather.main),
                      // Text(city.weatherData!.weather.description),
                      // Text(city.weatherData!.main.temperature.toString()),
                      // Text(city.weatherData!.main.feelsLike.toString()),
                      // Text(city.weatherData!.main.humidity.toString()),
                    ],
                  ));
            },
          );
        });
  }
}
