class Weather {
  final String cityName;
  final double temperature;
  final double tempMax;
  final double tempMin;
  final String mainCondition;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.tempMax,
    required this.tempMin,
    required this.mainCondition,
    required this.windSpeed,
  });

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