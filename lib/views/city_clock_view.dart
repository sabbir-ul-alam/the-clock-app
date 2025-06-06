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
  int? expandedIndex;

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
              return AnimatedTile(
                time: time,
                city: toBeginningOfSentenceCase(city.cityName.trim()),
                country: toBeginningOfSentenceCase(city.cityCountryName.trim()),
                weatherMain:
                    toBeginningOfSentenceCase(city.weatherData!.weather.main),
                weatherDescription: toBeginningOfSentenceCase(
                    city.weatherData!.weather.description),
                weatherTemperature:
                    city.weatherData!.main.temperature.round().toString(),
                weatherFeelsLike: city.weatherData!.main.feelsLike.round().toString(),
                weatherHumidity: city.weatherData!.main.humidity.round().toString(),
                isExpanded: expandedIndex == index,
                onTap: () {
                  setState(() {
                    expandedIndex = expandedIndex == index ? null : index;
                  });
                },
              );

              // return Container(
              //     margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
              //     padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 5),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.transparent),
              //       borderRadius: BorderRadius.circular(5),
              //       color: Colors.grey[200]
              //     ),
              //     child: Row(
              //       // spacing: 5,
              //       // mainAxisAlignment: MainAxisAlignment.spaceAround,
              //       mainAxisAlignment: MainAxisAlignment.spaceAround,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         SizedBox(
              //           width: 200,
              //           child: Text(
              //             time,
              //             style: TextStyle(color: Colors.black, fontSize: 50, wordSpacing: 5),
              //           ),
              //         ),
              //         const SizedBox(width: 20),
              //         Container(
              //           width: 1,
              //           height: 50,
              //           color: Colors.black, // Placeholder divider color
              //         ),
              //         // const SizedBox(width: 16),
              //         SizedBox(
              //           width: 120,
              //           child: Column(
              //             // mainAxisAlignment: MainAxisAlignment.start,
              //             crossAxisAlignment:CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 toBeginningOfSentenceCase(city.cityCountryName.trim()),
              //                 overflow: TextOverflow.ellipsis,
              //                 style:
              //                     TextStyle(color: Colors.black, fontSize: 12),
              //               ),
              //               Text(
              //                 toBeginningOfSentenceCase(city.cityName.trim()),
              //                 overflow: TextOverflow.ellipsis,
              //                 style:
              //                     TextStyle(color: Colors.black, fontSize: 24),
              //               ),
              //             ],
              //           ),
              //         ),
              //         // Text(city.weatherData!.weather.main),
              //         // Text(city.weatherData!.weather.description),
              //         // Text(city.weatherData!.main.temperature.toString()),
              //         // Text(city.weatherData!.main.feelsLike.toString()),
              //         // Text(city.weatherData!.main.humidity.toString()),
              //       ],
              //     ));
            },
          );
        });
  }
}

class AnimatedTile extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onTap;
  final String time;
  final String city;
  final String country;
  final String weatherMain;
  final String weatherDescription;
  final String weatherTemperature;
  final String weatherFeelsLike;
  final String weatherHumidity;

  const AnimatedTile(
      {super.key,
      required this.isExpanded,
      this.onTap,
      required this.time,
      required this.city,
      required this.country,
      required this.weatherMain,
      required this.weatherDescription,
      required this.weatherFeelsLike,
      required this.weatherHumidity,
      required this.weatherTemperature});

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile> {
  bool showExpandedContent = false;

  @override
  void didUpdateWidget(covariant AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle expansion
    if (widget.isExpanded && !oldWidget.isExpanded) {
      Future.delayed(Duration(milliseconds: 600), () {
        if (mounted && widget.isExpanded) {
          setState(() => showExpandedContent = true);
        }
      });
    }

    // Handle collapse immediately
    if (!widget.isExpanded && oldWidget.isExpanded) {
      setState(() => showExpandedContent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 5, right: 5, left: 5),
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10),
        height: widget.isExpanded ? 200 : 80,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // Time (top-left)
            AnimatedAlign(
              alignment:
                  widget.isExpanded ? Alignment.topLeft : Alignment(-.8, 0),
              duration: const Duration(milliseconds: 400),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: TextStyle(
                  fontSize: widget.isExpanded ? 16 : 50,
                  color: Colors.white,
                ),
                child: Text(widget.time),
              ),
            ),
            // Divider
            AnimatedPositioned(
              left: 230,
              height: widget.isExpanded ? 80 : 40,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 800),
              top: widget.isExpanded ? 50 : 10,
              // left: widget.isExpanded ? 100 : 140,
              // opacity: widget.isExpanded ? 1.0 : 0.0,
              child: Container(
                width: 1,
                height: 40,
                color: Colors.white,
              ),
            ),

            // Location (top-right)
            AnimatedAlign(
              alignment: widget.isExpanded ? Alignment.topRight : Alignment(0.7, 0),
              duration: const Duration(milliseconds: 400),
              child: SizedBox(
                width: 80, // Fixed width - adjust based on expected text length
                child: AnimatedDefaultTextStyle(

                  duration: const Duration(milliseconds: 400),
                  style: TextStyle(
                    fontSize: widget.isExpanded ? 12 : 14,
                    color: Colors.white,
                  ),
                  child: Text(
                    '${widget.country}\n${widget.city}',
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis, // Optional, to handle overflow
                    maxLines: 2,
                  ),
                ),
              ),
            ),

            // AnimatedAlign(
            //   alignment:
            //       widget.isExpanded ? Alignment.topRight : Alignment(.7, 0),
            //   duration: const Duration(milliseconds: 400),
            //   child: AnimatedDefaultTextStyle(
            //       duration: const Duration(milliseconds: 400),
            //       style: TextStyle(
            //         fontSize: widget.isExpanded ? 12 : 14,
            //         color: Colors.white,
            //       ),
            //       // textAlign: widget.isExpanded ? TextAlign.right : TextAlign.left,
            //       child: Text(widget.country + "\n" + widget.city,
            //       // overflow: TextOverflow.ellipsis
            //       )),
            // ),

            // Expanded Content
            if (showExpandedContent)
              Positioned(
                // top: 0,
                // left: 100,
                child: widget.isExpanded
                    ? Stack(children: [
                        Align(
                          alignment: Alignment(0, -.8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.weatherMain,
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.cloud, color: Colors.white),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment(0, 0),
                            child: Text("${widget.weatherTemperature}°",
                                style: TextStyle(
                                    fontSize: 64, color: Colors.white))),
                        Align(
                          alignment: Alignment(.7, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Feels like: ${widget.weatherFeelsLike}°",
                                  style: TextStyle(color: Colors.white)),
                              Text("Humidity: ${widget.weatherHumidity}%",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment(0, .8),
                          child: Text(widget.weatherDescription,
                              style: TextStyle(color: Colors.white)),
                        )
                      ])
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
