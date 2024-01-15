/// A model representing weather information for a specific location.
///
/// This class holds various weather-related data such as temperature, wind speed,
/// and general weather conditions for a given city.
class Weather {

  /// The name of the city.
  final String cityName;

  /// The current temperature.
  final double temperature;

  /// The maximum temperature.
  final double tempMax;

  /// The minimum temperature.
  final double tempMin;

  /// The main weather condition (e.g., Rain, Sunny).
  final String mainCondition;

  /// The wind speed.
  final double windSpeed;

  /// Constructs an instance of [Weather].
  ///
  /// Initializes all the fields with the provided values.
  Weather({
    required this.cityName,
    required this.temperature,
    required this.tempMax,
    required this.tempMin,
    required this.mainCondition,
    required this.windSpeed,
  });


  /// Creates a [Weather] object from a JSON map.
  ///
  /// This factory constructor initializes an instance of [Weather] using data
  /// provided in a [Map<String, dynamic>] format (commonly from a network response).
  ///
  /// [json] The JSON map containing weather data.
  factory Weather.fromJson(Map<String, dynamic> json){
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}