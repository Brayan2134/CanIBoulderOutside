import 'package:flutter/material.dart';
import '../models/search_model.dart'; // Assuming you have a Search model
import '../models/weather_model.dart';
import 'package:boulderconds/services/weather_services.dart';
import 'package:boulderconds/services/search_service.dart'; // Assuming you have a SearchService

class SearchResult extends StatefulWidget {
  final String cityName;

  const SearchResult({Key? key, required this.cityName}) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResult> {
  final _weatherService = WeatherService("eeb0f7ab19f20666b209b9027da3fe9b");
  Weather? _weather;
  Map<String, bool>? rainData;
  bool isLoading = true;

  _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather(widget.cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  void loadRainData() async {
    setState(() {
      isLoading = true; // Set to true when starting to load data
    });

    try {
      var data = await _weatherService.checkRainPeriods(widget.cityName);
      setState(() {
        rainData = data;
        isLoading = false; // Set to false once data is loaded
      });
    } catch (e) {
      print('An error occurred: $e');
      setState(() {
        isLoading = false; // Also set to false if there's an error
      });
      // Handle error state
    }
  }

  // Add this function to determine the climbing condition
  String getClimbingCondition(String rockType) {
    if (rainData == null) {
      return "Checking...";
    }

    bool rainedLast36 = rainData!['last_36_hours']!;
    bool rained36To72 = rainData!['36_to_72_hours']!;
    bool rainedOver72 = rainData!['over_72_hours']!;

    // Determine the condition based on rock type and rain data
    switch (rockType) {
      case "Sandstone":
      case "Conglomerate":
        if (rainedLast36) return "Don't Climb";
        if (rained36To72) return "Caution";
        return "Safe";
      case "Igneous":
      case "Metamorphic":
        if (rainedLast36) return "Caution";
        return "Safe";
      default:
        return "Unknown";
    }
  }

  Color getConditionColor(String condition) {
    switch (condition) {
      case "Safe":
        return Colors.green;
      case "Caution":
        return Colors.orange;
      case "Don't Climb":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    loadRainData();
  }

  Widget _buildRainDataDisplay() {
    if (rainData == null) {
      return Text("Loading rain data...");
    }
    return Column(
      children: [
        Text(
            'Last 36 hours: ${rainData!['last_36_hours']! ? 'Rained' : 'No Rain'}'),
        Text(
            '36 to 72 hours: ${rainData!['36_to_72_hours']! ? 'Rained' : 'No Rain'}'),
        Text(
            'Over 72 hours: ${rainData!['over_72_hours']! ? 'Rained' : 'No Rain'}'),
      ],
    );
  }


  Widget buildClimbingConditionTile(String rockType, String rockInfo) {
    String condition = getClimbingCondition(rockType);
    Color conditionColor = getConditionColor(condition);
    List<TextSpan> coloredTextSpans(String text) {
      const safeColor = Colors.green; // Color for "Safe"
      const cautionColor = Colors.orange; // Color for "Caution"
      const dontClimbColor = Colors.red; // Color for "Don't Climb"

      RegExp exp = RegExp(r'Safe:|Caution:|Do not climb');
      Iterable<RegExpMatch> matches = exp.allMatches(text);
      int lastMatchEnd = 0;
      List<TextSpan> spans = [];

      for (var match in matches) {
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
        }

        Color color = match[0] == 'Safe:' ? safeColor
            : match[0] == 'Caution:' ? cautionColor
            : dontClimbColor;
        spans.add(TextSpan(text: match[0], style: TextStyle(color: color)));
        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < text.length) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd)));
      }

      return spans;
    }

    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rockType),
          Text(condition, style: TextStyle(color: conditionColor)),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black), // Default text style
              children: coloredTextSpans(rockInfo),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
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
                          child: Text(_weather?.cityName ?? "Loading city..."),
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

                    _buildRainDataDisplay(),

                    // Rock Conditions
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Climbing conditions"),
                                buildClimbingConditionTile("Sandstone", "Sandstone is a sedimentary rock composed of mainly sand that absorbs moisture easily when it rains.As a result, climbing this rock type while it's still wet or damp has the potential to ruin the holds (and possibly route).Please use best judgment prior to climbing.\n\nSafe: Dry rock, no rain in over 72 hours.\nCaution: Dry rock, no rain in the last 36-72 hours.\nDo not climb: Wet rock (or/and) rain within the last 36 hours."),
                                buildClimbingConditionTile("Conglomerate", "Conglomerate is a type of sedimentary rock that is comprised of rounded pebbles and sand. As a result, it's best to avoid climbing this rock type while the route is wet or damp. Furthermore, climbing wet routes leads to slippery and possible breaking of holds. \n\nSafe: Dry rock, no rain in the last 36-72 hours. \nCaution: Dry rock, no rain in the last 36 hours. \nDo not climb: Wet rock (and/or) rain in the last 36 hours."),
                                buildClimbingConditionTile("Igneous", "Igneous rock is one of the three main rock types made in the earths mantle or crust. Some examples of Igneous rock include diorite, gabbro, granite, and pegmatite.They are generally safe to climb on as the rock doesn't absorb moisture well.Be advised that wet Igneous rock is moderately slippery.\n\nSafe: Dry rock, no rain in the last 36 hours.\nCaution: Wet rock, rain in the last 36 hours."),
                                buildClimbingConditionTile("Metamorphic", "Metamorphic rock is formed when existing rocks are banded together to create a new rock. Some examples of Metamorphic rock include gneiss, quartzite, marble, and soapstone. They are generally safe to climb on as the rock doesn't absorb moisture well.\n\nSafe: Dry rock, no rain in the last 36 hours.\nCaution: Wet rock, rain in the last 36 hours."),
                              ],
                            ),
                          ),
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
    );
  }
}
