import 'package:flutter/material.dart';
import '../viewmodels/city_clock_viewmodel.dart';
import '../viewmodels/alarm_viewmodel.dart';
import 'city_clock_view.dart';
import 'alarm.dart';
import 'search_cities.dart';
import 'alarm_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _isCitySelected = true;
  bool _isAlarmSelected = false;

  CityClockViewModel cityClockList = CityClockViewModel();
  AlarmViewmodel alarmViewmodel = AlarmViewmodel();

  void selectTab(int index) {
    setState(() {
      _tabIndex = index;
      _isCitySelected = _tabIndex == 0 ? true : false;
      _isAlarmSelected = _tabIndex == 1 ? true : false;
    });
  }

  Future<void> _navigateToSearchPage(BuildContext context) async {
    final cityData = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SeachCities()));
    cityClockList.addCity(cityData);
    // if (!context.mounted) return;
  }

  void _showTimePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromRGBO(217, 217, 217, 100),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: AlarmModal(),
        );
      },
    );
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      cityClockList.fetchClockCities();
    });
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: _tabIndex == 0 ? Text('World Clock') : Text('Alarm'),
        centerTitle: true,
      ),
      body: SafeArea(

        bottom: true,
        child: _tabIndex == 0
            ? CityClockTab(cityClockList: cityClockList)
            : AlarmTab(alarmViewmodel: alarmViewmodel),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            Expanded(
                child: IconButton(
              isSelected: _isCitySelected,
              onPressed: () => selectTab(0),
              icon: const Icon(
                Icons.maps_home_work_outlined,
                color: Colors.grey,
              ),
              selectedIcon:
                  const Icon(Icons.maps_home_work, color: Colors.grey),
            )),
            Expanded(
                child: IconButton(
              isSelected: _isAlarmSelected,
              onPressed: () => selectTab(1),
              icon: const Icon(Icons.timer_outlined, color: Colors.grey,),
              selectedIcon: const Icon(Icons.timer, color: Colors.grey,),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[350],
        onPressed: () {
          if (_tabIndex == 0) {
            _navigateToSearchPage(context);
          } else {
            _showTimePickerDialog(context);
          }
        },
        child: const Icon(Icons.add, color: Colors.black,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,


    );
  }
}
