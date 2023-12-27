import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService{

  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async{
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=imperial'));

    if (response.statusCode == 200){
      return Weather.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception('Could not load weather data :(');
    }
  }

  Future<String> getCurrentCity() async{

    // Get location permission from the user
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    // Fetch current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // Covert location into a list of placemark objects
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    // Extract the city name from the first placemark
    String? city = placemarks[0].locality;

    return city ?? ""; // Return blank string if cannot get data
  }


  Future<Map<String, bool>> checkRainPeriods(String cityName) async {
    // OpenWeatherMap API endpoint for 5-day forecast (3-hour interval data)
    String url = 'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey';

    Map<String, bool> rainPeriods = {
      'last_36_hours': false,
      '36_to_72_hours': false,
      'over_72_hours': false
    };

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        for (var i = 0; i < data['list'].length; i++) {
          var weather = data['list'][i]['weather'][0]['main'];
          var dateTime = DateTime.parse(data['list'][i]['dt_txt']);

          // Assuming the data is in chronological order
          if (dateTime.isAfter(DateTime.now().subtract(Duration(hours: 36)))) {
            if (weather == 'Rain') rainPeriods['last_36_hours'] = true;
          } else if (dateTime.isBefore(DateTime.now().subtract(Duration(hours: 36))) &&
              dateTime.isAfter(DateTime.now().subtract(Duration(hours: 72)))) {
            if (weather == 'Rain') rainPeriods['36_to_72_hours'] = true;
          } else {
            if (weather == 'Rain') rainPeriods['over_72_hours'] = true;
          }
        }
        return rainPeriods;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return rainPeriods;
      }
    } catch (e) {
      print('An error occurred: $e');
      return rainPeriods;
    }
  }
}