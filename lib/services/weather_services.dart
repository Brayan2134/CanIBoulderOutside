import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import '../services/settings_service.dart';


/// A service class for fetching weather-related data.
class WeatherService{

  static const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";
  String? apiKey;
  WeatherService();
  DateTime? _lastFetchTime;
  String? _lastUnitType;

  // Public getters
  DateTime? get lastFetchTime => _lastFetchTime;
  String? get lastUnitType => _lastUnitType;

  /// Sets the API key for accessing weather data.
  ///
  /// [key] The API key as a [String].
  setApiKey(String key) {
    apiKey = key;
  }


  /// Fetches weather data for a given city name.
  ///
  /// [cityName] The name of the city.
  /// Returns a [Future] that resolves to a [Weather] object.
  /// Throws an [Exception] if the API key is not initialized or if the request fails.
  Future<Weather> getWeather(String cityName) async{

    // Ensure apiKey is not null
    if (apiKey == null) {
      throw Exception('API key is not initialized.');
    }

    // Get the unit type from the SettingsService (either C or F).
    String unitType = await SettingsService().getCurrentUnitType();

    _lastFetchTime = DateTime.now();
    _lastUnitType = unitType;

    // Get the response code from the server.
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=$unitType'));

    // If connection to the server is successful, decode JSON data from server.
    if (response.statusCode == 200){
      return Weather.fromJson(jsonDecode(response.body));
    }
    // If connection to the server fails, throw Exception.
    else{
      throw Exception('Could not load weather data :(');
    }
  }


  /// Retrieves the current city based on the device's location.
  ///
  /// Returns a [Future] that resolves to the city name as a [String].
  /// Returns an empty string if the city name cannot be determined.
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


  /// Checks for rain periods for a given city.
  ///
  /// [cityName] The name of the city.
  /// Returns a [Future] that resolves to a [Map] indicating rain periods.
  Future<Map<String, bool>> checkRainPeriods(String cityName) async {

    // OpenWeatherMap API endpoint for 5-day forecast (3-hour interval data)
    // TODO: REPLACE WITH HISTORICAL API IF OPENWEATHERMAP SUPPORT RESPONDS!!!
    String url = 'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey';

    // Map with the possible rain periods for bouldering.
    Map<String, bool> rainPeriods = {
      'last_36_hours': false,
      '36_to_72_hours': false,
      'over_72_hours': false
    };

    try {

      // Attempt a connection to the openweathermap server.
      var response = await http.get(Uri.parse(url));

      // Assuming the network connection is successful.
      if (response.statusCode == 200) {
        var data = json.decode(response.body); // Data from server

        for (var i = 0; i < data['list'].length; i++) {

          var weather = data['list'][i]['weather'][0]['main'];
          var dateTime = DateTime.parse(data['list'][i]['dt_txt']);

          // Check if the time is within the last 36 hours
          if (dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 36)))) {
            if (weather == 'Rain') rainPeriods['last_36_hours'] = true;
          }
          // Check if the time is between 36 to 72 hours ago
          else if (dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 72)))) {
            if (weather == 'Rain') rainPeriods['36_to_72_hours'] = true;
          }
          // All other times are over 72 hours ago
          else {
            if (weather == 'Rain') rainPeriods['over_72_hours'] = true;
          }
        }
        return rainPeriods;
      }

      // If the openweathermap API doesnt connect properly, display error message.
      else {
        // Request failed.
        return rainPeriods;
      }
    }
    // In the event that the try catch statement cannot be executed, produce an error.
    catch (e) {
      // An error has occured with the try/catch statement?
      return rainPeriods;
    }
  }

  /*
  * HISTORICAL API REPLACEMENT
  * --------------------------
  *
  * USE IF OPENWEATHERMAP GRANTS API ACCESS BECAUSE OF STUDENT STATUS:
  * 
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
  * -----------------------------------------------------------------------------------------------------------
  * */


  /// Gets the current unit type for temperature display.
  ///
  /// Returns a [Future] that resolves to the unit type as a [String].
  /// Throws an [Exception] for invalid unit types.
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