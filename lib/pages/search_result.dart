import 'package:flutter/material.dart';
import '../models/search_model.dart'; // Assuming you have a Search model
import '../models/weather_model.dart';
import 'package:boulderconds/services/weather_services.dart';
import 'package:boulderconds/services/search_service.dart'; // Assuming you have a SearchService

class SearchResult extends StatefulWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultPageState();
}


class _SearchResultPageState extends State<SearchResult> {
  final _weatherService = WeatherService("eeb0f7ab19f20666b209b9027da3fe9b");
  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [


                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child:
                          Text(_weather?.cityName ?? "Loading city..."),
                        ),
                        Expanded(child: Container()),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                              '${_weather?.temperature.round()}\u2109 right now'),
                        ),
                      ],
                    ),


                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Text(
                                  '${_weather?.tempMax.round()}\u2109 high today'),
                              Text(
                                  '${_weather?.tempMin.round()}\u2109 low today')
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                              '${_weather?.windSpeed.round()} mph wind speed'),
                        ),
                      ],
                    ),


                    // Rock Conditions
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Container(
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Climbing conditions"),
                                  ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Sandstone"),
                                        Text("Safe",
                                            style: TextStyle(
                                                color: Colors.green)),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Info: "
                                            "Sandstone is a sedimentary rock composed of mainly sand that absorbs moisture easily when it rains. "
                                            "As a result, climbing this rock type while it's still wet or damp has the potential "
                                            "to ruin the holds (and possibly route). "
                                            "Please use best judgment prior to climbing.\n\n"
                                            "Safe: Dry rock, no rain in over 72 hours.\n"
                                            "Caution: Dry rock, no rain in the last 36-72 hours.\n"
                                            "Don't Climb: Wet rock (or/and) rain within the last 36 hours."),
                                      ),
                                    ],
                                  ),


                                  // Conglomerate Rock Condition
                                  ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Conglomerate"),
                                        Text("Safe", style: TextStyle(color: Colors.green)), // Customize the style as needed
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Info: "
                                            "Conglomerate is a type of sedimentary rock that is comprised of rounded pebbles and sand. "
                                            "As a result, it's best to avoid climbing this rock type while the route is wet or damp. "
                                            "Furthermore, climbing wet routes leads to slippery and possible breaking of holds.\n\n"
                                            "Safe: Dry rock, no rain in the last 36-72 hours.\n"
                                            "Caution: Dry rock, no rain in the last 36 hours.\n"
                                            "Don't climb: Wet rock (and/or) rain in the last 36 hours."
                                        ),
                                      ),
                                    ],
                                  ),


                                  // Igneous Rock Condition
                                  ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Igneous"),
                                        Text("Safe", style: TextStyle(color: Colors.green)), // Customize the style as needed
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Info: "
                                            "Igneous rock is one of the three main rock types made in "
                                            "the earths mantle or crust. Some examples of Igneous rock include "
                                            "diorite, gabbro, granite, and pegmatite. "
                                            "They are generally safe to climb on as the rock doesn't absorb moisture well. "
                                            "Be advised that wet Igneous rock is moderately slippery.\n\n"
                                            "Safe: Dry rock, no rain in the last 36 hours.\n"
                                            "Caution: Wet rock, rain in the last 36 hours."),
                                      ),
                                    ],
                                  ),


                                  // Metamorphic Rock Condition
                                  ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Metamorphic"),
                                        Text("Safe", style: TextStyle(color: Colors.green)), // Customize the style as needed
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Info: "
                                            "Metamorphic rock is formed when existing rocks are banded together to create a new rock. "
                                            ""
                                            "Some examples of Metamorphic rock include gneiss, quartzite, marble, and soapstone. "
                                            "They are generally safe to climb on as the rock doesn't absorb moisture well.\n\n"
                                            "Safe: Dry rock, no rain in the last 36 hours.\n"
                                            "Caution: Wet rock, rain in the last 36 hours."),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),



      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation based on the selected index
          switch (index){
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
