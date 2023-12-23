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
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // City Name
          Text(_weather?.cityName ?? "Loading city..."),

          // temperature
          Text('${_weather?.temperature.round()}"C"'),
          ],
        ),
      )
    );
  }
}
