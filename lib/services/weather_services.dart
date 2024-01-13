import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import '../services/settings_service.dart';
import 'package:http/http.dart' as http;

class WeatherService{

  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  String? apiKey;
  WeatherService();
  DateTime? _lastFetchTime;
  String? _lastUnitType;

  // Public getters
  DateTime? get lastFetchTime => _lastFetchTime;
  String? get lastUnitType => _lastUnitType;

  setApiKey(String key) {
    apiKey = key;
  }

  Future<Weather> getWeather(String cityName) async{

    // Ensure apiKey is not null
    if (apiKey == null) {
      throw Exception('API key is not initialized.');
    }

    String unitType = await SettingsService().getCurrentUnitType(); // Retrieve unit type

    _lastFetchTime = DateTime.now();
    _lastUnitType = unitType;

    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=$unitType'));

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


  Future<Map<String, bool>> checkRainPeriods() async {
    Map<String, bool> rainPeriods = {
      'last_36_hours': false,
      '36_to_72_hours': false,
      'over_72_hours': false
    };

    // Get current position using Geolocator
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Current time in UNIX timestamp
    int thirtySixHoursAgo = currentTime - 129600; // 36 hours ago in UNIX timestamp
    int seventyTwoHoursAgo = currentTime - 259200; // 72 hours ago in UNIX timestamp

    // API URL for historical data with latitude and longitude
    String url = 'https://history.openweathermap.org/data/2.5/history/city?lat=${position.latitude}&lon=${position.longitude}&type=hour&start=$seventyTwoHoursAgo&end=$currentTime&appid=$apiKey';

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Iterate over the historical data to check for rain
        for (var entry in data['list']) {
          var timestamp = entry['dt'];
          var weather = entry['weather'][0]['main'];

          if (timestamp >= thirtySixHoursAgo && weather == 'Rain') {
            rainPeriods['last_36_hours'] = true;
          } else if (timestamp >= seventyTwoHoursAgo && timestamp < thirtySixHoursAgo && weather == 'Rain') {
            rainPeriods['36_to_72_hours'] = true;
          } else if (timestamp < seventyTwoHoursAgo && weather == 'Rain') {
            rainPeriods['over_72_hours'] = true;
          }
        }

        return rainPeriods;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return rainPeriods;
      }
    } catch (e) {
      print('An error has occurred: $e');
      return rainPeriods;
    }
  }



  Future<String> get getUnitType async {
    String unitType = await SettingsService().getCurrentUnitType();
    unitType = unitType.toLowerCase();

    if (unitType == 'imperial') {
      return 'F';
    } else if (unitType == 'metric') {
      return 'C';
    } else {
      // Handle unexpected unitType value
      throw Exception('Invalid unit type');
    }
  }



}