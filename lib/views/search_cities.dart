import 'package:flutter/material.dart';
import '../utils/logger_service.dart';
import '../viewmodels/search_cities_viewmodel.dart';
import 'package:intl/intl.dart';


class SeachCities extends StatelessWidget{
  const SeachCities({super.key});

  @override
  Widget build( BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        leading: BackButton(
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text('Search City'),
        centerTitle: true,

      ),
      body: SearchDbWhileTyping(),

    );
  }

}

class SearchDbWhileTyping extends StatefulWidget{
  const SearchDbWhileTyping({super.key});

  @override
  State<SearchDbWhileTyping> createState() => _SearchDbWhileTypingSate();

}

class _SearchDbWhileTypingSate extends State<SearchDbWhileTyping>{

  final searchController  = TextEditingController();
  SearchCitiesViewModel searchCitiesViewModel = SearchCitiesViewModel();


  @override
  void initState(){
    super.initState();
    searchController.addListener(_getCities);
  }

  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }

  void _getCities(){
    searchCitiesViewModel.removeTheCurrentList();
    final nameOFtheCity = searchController.text;
    LoggerService.debug(nameOFtheCity);
    if(nameOFtheCity!="") {
      searchCitiesViewModel.getCitiesFromDbByName(nameOFtheCity);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
            TextField(
              decoration: InputDecoration(
                  hintText: 'Enter the name of a city',
                  contentPadding: EdgeInsets.all(20),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey
                  )
                )
              ),

              controller: searchController,
            ),
          Expanded(
          child: ListenableBuilder(
              listenable: searchCitiesViewModel,
              builder: (context,child){
                return ListView.builder(
                    itemCount: searchCitiesViewModel.searchedCityList.length,
                    itemBuilder: (context, index){
                      final city = searchCitiesViewModel.searchedCityList[index];
                      return InkWell(

                        child: Container(
                        height: 20,
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(toBeginningOfSentenceCase('${city.cityName},${city.cityStateName},${city.cityCountryName}'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(),)
                            ),
                            Text('${city.cityTimeOffSet}')
                          ],
                        ),
                        //
                      ),
                        onTap: (){
                          Future.delayed(const Duration(milliseconds: 150),()
                          {
                            if (context.mounted) Navigator.pop(context,city);
                          });
                        },
                      );
                    }
                );
              }
          ),
          ),


          ],
        ),
      );
  }

}

