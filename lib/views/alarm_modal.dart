import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../viewmodels/alarm_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/alarm.dart';
import 'ringtone_picker_modal.dart';
import '../services/ringtone_picker_service.dart';

class AlarmModal extends StatefulWidget {
  Alarm? alarm;
  AlarmModal({super.key, this.alarm});

  @override
  AlarmModalState createState() => AlarmModalState();
}

class AlarmModalState extends State<AlarmModal> {
  RingTone? selectedTone;
  int hour = 12;
  int minute = 0;
  bool isAM = true;

  bool selectingHour = true;
  bool isAlarm = true;
  List<bool> selectedDays = List.generate(7, (index) => false);
  final alarmViewmodel = AlarmViewmodel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.alarm != null) {
      hour = widget.alarm!.alarmTime.hour;
      minute = widget.alarm!.alarmTime.minute;
      isAM = widget.alarm!.alarmTime.hour < 12;
      isAlarm = widget.alarm!.isAlarm;
      for (var day in widget.alarm!.listOfDays!) {
        selectedDays[day.dayNumber] = true;
      }
      selectedTone = widget.alarm!.ringTonePath;
    }
    else{
      _loadLastSelectedTone();
    }
  }
  void _loadLastSelectedTone() async {
    final lastTone = await RingtonePickerService.getLastSelectedTone();
    if (lastTone != null) {
      setState(() {
        selectedTone = RingTone(lastTone['name']!, lastTone['uri']!);
      });
    }
  }




  // double handAngle = 270*pi/180;
  double hourHandAngle = 0 - pi / 2;
  double minHandAngle = 0 - pi / 2;

  DateTime _getTime(int hour, int min, bool isAm) {
    if (isAm) {
      if (hour == 12) {
        hour = 0;
      }
    } else if (!isAm) {
      if (hour != 12) {
        hour = 12 + hour;
      }
    }
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, min);
  }

  void saveAlarm() {
    DateTime alarmTime = _getTime(hour, minute, isAM);
    alarmViewmodel.saveNewAlarm(alarmTime, selectedDays, isAlarm, selectedTone!);
  }

  void updateAlarm(Alarm alarm) {

    final oldDays = (alarm.listOfDays != null)
        ? List<Day>.from(alarm.listOfDays!.cast<Day>())
        : <Day>[];

    alarm.alarmTime = _getTime(hour, minute, isAM);
    alarm.listOfDays = alarmViewmodel.convertToDayEnums(selectedDays);
    alarm.isAlarm = isAlarm;
    alarm.ringTonePath = selectedTone;

    alarmViewmodel.updateAlarm(alarm, oldDays: oldDays);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.,
            children: [
              Expanded(
                  child: Row(children: [
                _timeBox(hour.toString().padLeft(2, '0'), 'hour'),
                Text(':', style: TextStyle(fontSize: 30, letterSpacing: 20)),
                _timeBox(minute.toString().padLeft(2, '0'), 'min'),
                SizedBox(width: 20),
                Column(
                  children: [
                    _amPmButton('AM', isAM, () => setState(() => isAM = true)),
                    _amPmButton(
                        'PM', !isAM, () => setState(() => isAM = false)),
                  ],
                ),
              ])),
              InkWell(
                onTap: () async {
                  final selected =
                      await showModalBottomSheet<Map<String, String>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: RingtonePickerModal(
                        selectedUri:
                            selectedTone?.tonePath, // pass existing selection
                      ),
                    ),
                  );

                  if (selected != null) {
                    setState(() {
                      selectedTone =
                          RingTone(selected['name']!, selected['uri']!);
                    });
                    // Optionally save to SharedPreferences for future default use
                  }else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No ringtone selected")),
                    );
                  }

                },
                child: Ink(
                  height: 50,
                  width: 60,
                  padding: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: SvgPicture.asset('assets/icons/music.svg'),
                ),
              )
            ],
          ),
          // SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildClockDial(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                String day = entry.value;
                return _dayButton(day, index);
              }).toList(),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _modeButton('Alarm', isAlarm),
              Text(
                ' | ',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              _modeButton('Prayer', isAlarm),
            ],
          ),
          // SizedBox(height: 10),
          //
          // SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.grey[300],
              ),
              onPressed: () {
                widget.alarm != null ? updateAlarm(widget.alarm!) : saveAlarm();
                Navigator.pop(context);
              },
              child: Text(
                widget.alarm != null ? 'Update' : 'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _modeButton(String type, bool alarm) {
    bool selected;
    if (type == 'Alarm') {
      selected = alarm ? true : false;
    } else {
      selected = alarm ? false : true;
    }

    return InkWell(
      onTap: () {
        setState(() {
          isAlarm = type == 'Alarm' ? true : false;
        });
      },
      child: Ink(
        child: Text(
          type,
          style: TextStyle(
              fontSize: 30,
              color: selected ? Colors.grey[600] : Colors.grey[350]),
        ),
      ),
    );
  }

  Widget _buildClockDial() {
    return GestureDetector(
      onPanUpdate: (details) {
        Offset center = Offset(120, 120);
        double angle = atan2(details.localPosition.dy - center.dy,
            details.localPosition.dx - center.dx);
        double adjustedAngle = angle + pi / 2;
        if (adjustedAngle < 0) adjustedAngle += 2 * pi;
        setState(() {
          if (selectingHour) {
            hour = ((adjustedAngle / (2 * pi) * 12) % 12).round();
            // hour = ((angleInDegree / 360 * 12) % 12).round();
            if (hour == 0) hour = 12;
            hourHandAngle = ((hour / 12) * 2 * pi) - pi / 2;
            // handAngle= angle;
          } else {
            minute = ((adjustedAngle / (2 * pi) * 60) % 60).round();
            if (minute == 60) minute = 0;
            minHandAngle = ((minute / 60) * 2 * pi) - pi / 2;
            // handAngle = angle;
          }
        });
      },
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey

            // border: Border.all(color: Colors.black)

            ),
        child: CustomPaint(
          painter: ClockPainter(selectingHour, hourHandAngle, minHandAngle),
        ),
      ),
    );
  }

  Widget _timeBox(String value, String hourMin) {
    bool isSelected;
    if (hourMin == 'hour') {
      isSelected = selectingHour ? true : false;
    } else {
      isSelected = selectingHour ? false : true;
    }
    return InkWell(
      // splashColor: Colors.black,
      // radius:10,

      child: Ink(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(value,
            style: TextStyle(
              fontSize: 35,
              color: isSelected ? Colors.white : Colors.black,
            ) //, fontWeight: FontWeight.bold),

            ),
      ),

      onTap: () {
        if (hourMin == 'hour') {
          setState(() => selectingHour = true);
        } else {
          setState(() => selectingHour = false);
        }
      },
    );
  }

  Widget _amPmButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _dayButton(String day, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedDays[index] = !selectedDays[index]);
      },
      child: Container(
          height: 40,
          width: 40,
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selectedDays[index] ? Colors.grey : Colors.grey[300],
            // border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                  color: selectedDays[index] ? Colors.white : Colors.black,
                  fontSize: 14),
            ),
          )),
    );
  }
}

class ClockPainter extends CustomPainter {
  final bool selectingHour;
  final double hourHandAngle;
  final double minHandAngle;
  ClockPainter(this.selectingHour, this.hourHandAngle, this.minHandAngle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    int divisions = selectingHour ? 12 : 60;
    for (int i = 1; i <= divisions; i++) {
      double angle = (i / divisions) * 2 * pi;
      Offset start = Offset(size.width / 2 + cos(angle) * 100,
          size.height / 2 + sin(angle) * 100);
      Offset end = Offset(size.width / 2 + cos(angle) * 120,
          size.height / 2 + sin(angle) * 120);
      canvas.drawLine(start, end, paint);
    }
    double handAngle = selectingHour ? hourHandAngle : minHandAngle;

    Offset handEnd = Offset(size.width / 2 + cos(handAngle) * 80,
        size.height / 2 + sin(handAngle) * 80);
    canvas.drawLine(Offset(size.width / 2, size.height / 2), handEnd,
        paint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
