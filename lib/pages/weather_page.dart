import 'package:boulderconds/services/weather_services.dart';
import 'package:flutter/material.dart';

import '../models/weather_model.dart';


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>{

  // api key
  final _weatherService = WeatherService("eeb0f7ab19f20666b209b9027da3fe9b");
  Weather? _weather;

  // fetch weather
  _fetchWeather() async{

    // Get current city
    String cityName = await _weatherService.getCurrentCity();

    // get weather for city
    try{
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;

      });
    }
    catch (e){
      print(e);
    }
  }

  // weather animations

  // Init State
  @override
  void initState(){
    super.initState();

    // Fetch weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [


            Row(
              children: [

                // Current City
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(_weather?.cityName ?? "Loading city..."),
                ),

                // Expanded widget to create space between city and temperature
                Expanded(child: Container()),

                // Current temperature
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('${_weather?.temperature.round()}\u2109 right now'),
                ),
              ],
            ),


            // Temperatures and wind speed
            Row(
              children: [
                // High & Low temperature
                Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text('${_weather?.tempMax.round()}\u2109 high today'),
                        Text('${_weather?.tempMin.round()}\u2109 low today')
                      ],
                    ),
                ),

                // Expanded widget to create space between city and temperature
                Expanded(child: Container()),

                // Wind Speed
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('${_weather?.windSpeed.round()} mph wind speed'),
                ),
              ],
            ),


            // Rock Conditions
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Container(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sandstone Rock Condition
                          ExpansionTile(
                            title: Text("Sandstone rock conditions"),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Additional information here"),
                              ),
                            ],
                          ),

                          // Conglomerate Rock Condition
                          ExpansionTile(
                            title: Text("Conglomerate rock conditions"),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Additional information here"),
                              ),
                            ],
                          ),

                          // Igneous Rock Condition
                          ExpansionTile(
                            title: Text("Igneous rock conditions"),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Additional information here"),
                              ),
                            ],
                          ),

                          // Metamorphic Rock Condition
                          ExpansionTile(
                            title: Text("Metamorphic rock conditions"),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Additional information here"),
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
            
          ],
        ),
      ),
    );
  }



}
