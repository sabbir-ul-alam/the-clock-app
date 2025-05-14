import 'package:flutter/material.dart';
import 'package:theclockapp/models/alarm.dart';
import '../viewmodels/alarm_viewmodel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'alarm_modal.dart';
import '../utils/alarm_permission_helper.dart';

class AlarmTab extends StatefulWidget {
  final AlarmViewmodel alarmViewmodel;

  const AlarmTab({super.key, required this.alarmViewmodel});

  @override
  AlarmTabState createState() => AlarmTabState();
}

class AlarmTabState extends State<AlarmTab> {
  double _dividerPosition = 0.5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.alarmViewmodel.fetchAllAlarms();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Safe to use `context`, `await`, dialogs, or push routes here
      await ensureExactAlarmPermission(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   // Safe to use `context`, `await`, dialogs, or push routes here
    //   await ensureExactAlarmPermission(context);
    // });

    return LayoutBuilder(builder: (context, constraints) {

      final totalHeight = constraints.maxHeight;
      final topHeight = totalHeight * _dividerPosition;
      final bottomHeight = totalHeight * (1 - _dividerPosition) - 8;
      return Column(

        children: [
          SizedBox(
              height: topHeight,
              child: Stack(
                children: [
                  Container(

                    margin:
                        const EdgeInsets.all(8.0), // acts like outer padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black),
                      color: Colors.grey[50],
                      // color: Theme.of(context).scaffoldBackgroundColor
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CategoryContainer(
                        alarmViewmodel: widget.alarmViewmodel,
                        category: 'Prayer'),
                  ),
                  Positioned(
                    top: -4,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        // borderRadius: BorderRadius.only(
                        //   topLeft: Radius.circular(12),
                        //   bottomRight: Radius.circular(12),
                        // ),
                      ),
                      child: Text(
                        'Prayer',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              setState(() {
                _dividerPosition += details.delta.dy / totalHeight;
                _dividerPosition = _dividerPosition.clamp(0.2, .8);
              });
            },
            child: Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          SizedBox(
              height: bottomHeight,
              child: Stack(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.all(8.0), // acts like outer padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black),
                      color: Colors.grey[50]
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CategoryContainer(
                        alarmViewmodel: widget.alarmViewmodel,
                        category: 'Alarm'),
                  ),
                  Positioned(
                    top: -4,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        // borderRadius: BorderRadius.only(
                        //   topLeft: Radius.circular(12),
                        //   bottomRight: Radius.circular(12),
                        // ),
                      ),
                      child: Text(
                        'Alarm',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      );
    });
  }
}

class CategoryContainer extends StatelessWidget {
  final AlarmViewmodel alarmViewmodel;
  final String category;

  const CategoryContainer(
      {super.key, required this.alarmViewmodel, required this.category});

  void _showTimePickerDialog(BuildContext context, var alarm) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(217, 217, 217, 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: AlarmModal(
            alarm: alarm,
          ),
        );
      },
    );
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: alarmViewmodel,
      builder: (context, child) {
        return ListView.builder(
          // margin: const EdgeInsets.symmetric(
          //     horizontal: 12, vertical: 6),
          // padding: const EdgeInsets.symmetric(horizontal: 12),

          itemCount: alarmViewmodel.listOfAlarm.length,
          itemBuilder: (context, index) {
            final alarm = alarmViewmodel.listOfAlarm[index];
            if (alarm.isAlarm! && category != 'Alarm') {
              return SizedBox.shrink();
            } else if (!alarm.isAlarm! && category != 'Prayer') {
              return SizedBox.shrink();
            }
            final String iconPath = (alarm.isEnabled ?? false)
                ? 'assets/icons/check.svg'
                : 'assets/icons/cross.svg';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
              ),
              clipBehavior: Clip.antiAlias,
              child: Dismissible(
                key: Key(alarm.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.grey,

                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(
                              color: Colors.white,
                              ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  //delete code here
                  alarmViewmodel.deleteAlarm(alarm);
                },
                child: InkWell(
                  onTap: () => _showTimePickerDialog(context, alarm),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (alarm.isEnabled ?? true) {
                              alarm.isEnabled = false;
                            } else {
                              alarm.isEnabled = true;
                            }
                            alarmViewmodel.updateAlarm(alarm);
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2)),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(iconPath),
                            ),
                          ),
                        ),
                        // Time display
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('hh:mm a').format(alarm.alarmTime),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  String day = entry.value;
                                  // final isActive = alarm.listOfDays!.contains(day);
                                  final isActiveDay = alarmViewmodel
                                      .containsDay(alarm.listOfDays!, index);
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isActiveDay
                                          ? Colors.grey
                                          : Colors.grey[350],
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      day,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
