import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import 'package:boulderconds/services/weather_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService();
  Weather? _weather;
  Map<String, bool>? rainData;
  bool isLoading = true;
  String _currentUnit = 'Metric';
  final _storage = const FlutterSecureStorage();


  _initApiKey() async {
    String? apiKey = await _storage.read(key: "openWeatherMapAPIKey");
    if (apiKey != null) {
      _weatherService.setApiKey(apiKey);
      _loadSettings();
      _fetchWeather();
      loadRainData();
    } else {
      // Handle the case where API key is not found
      throw Exception("API KEY NOT FOUND!");
    }
  }



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

  void loadRainData() async {
    String cityName = await _weatherService.getCurrentCity();

    setState(() {
      isLoading = true; // Set to true when starting to load data
    });

    try {
      var data = await _weatherService.checkRainPeriods(cityName);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUnit = prefs.getString('unitType') ?? 'Metric';
    });
  }

  @override
  void initState() {
    super.initState();
    _initApiKey();
  }

  Widget _buildRainDataDisplay() {
    if (rainData == null) {
      return const Text("Loading rain data...");
    }
    return Column(
      children: [
        Text(
          'Last 36 hours: ${rainData!['last_36_hours']! ? 'Rained' : 'No Rain'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '36 to 72 hours: ${rainData!['36_to_72_hours']! ? 'Rained' : 'No Rain'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Over 72 hours: ${rainData!['over_72_hours']! ? 'Rained' : 'No Rain'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
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

        Color color = match[0] == 'Safe:'
            ? safeColor
            : match[0] == 'Caution:'
                ? cautionColor
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
          Text(rockType, style: TextStyle(color: Colors.white),),
          Text(condition, style: TextStyle(color: conditionColor)),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white), // Default text style
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
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(24, 24, 24, 1),
                  Color.fromRGBO(26, 29, 55, 1),
                  // Replace with your desired colors
                ],
              ),
            ),
          ),
          Column(
            children: <Widget>[
              AppBar(
                title: Text(
                  _weather?.cityName ?? "Loading city...",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                // Make the AppBar transparent.
                elevation: 0, // Remove shadow.
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _weatherService.getUnitType,
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    // Display a loading indicator or a placeholder
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    // Handle the error
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // Display the temperature with the unit
                                    return Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(80, 82, 94, 1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_weather?.temperature.round()}°${snapshot.data}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        // Row to contain both FractionallySizedBoxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _weatherService?.getUnitType,
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    // Display a loading indicator or a placeholder
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    // Handle the error
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    // Display the temperature with the unit
                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(80, 82, 94, 1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_weather?.tempMax.round()}°${snapshot.data} High'
                                            '\n'
                                            '${_weather?.tempMin.round()}°${snapshot.data} Low',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Spacing between the containers
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(80, 82, 94, 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_weather?.windSpeed.round()} wind'
                                      '\n'
                                      '${_weather?.mainCondition}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Center the container in the row
                          children: [
                            Expanded(
                              // Use Expanded if you want the container to take the full width
                              child: Container(
                                padding: EdgeInsets.all(8),
                                // Padding inside the container
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(80, 82, 94, 1),
                                  // Choose a suitable color
                                  borderRadius: BorderRadius.circular(
                                      12), // Rounded corners
                                ),
                                child:
                                    _buildRainDataDisplay(), // Your custom widget for rain data
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15,),

                        Column(
                          children: <Widget>[
                            _climbingConditionsContainer(),
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
          switch (index) {
            case 0:
              // No need to navigate, already on the WeatherPage
              break;
            case 1:
              Navigator.pushNamed(context, '/search');
              break;
            case 2:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ), // Your existing bottom navigation bar code
    );
  }

  // Helper method to create a container for all climbing condition tiles
  Widget _climbingConditionsContainer() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8), // Vertical spacing around the container
      padding: EdgeInsets.all(8), // Padding inside the container
      decoration: BoxDecoration(
        color: Color.fromRGBO(80, 82, 94, 1), // Container color
        borderRadius: BorderRadius.circular(12), // Rounded corners
        // Add any other styling you need for the container
      ),
      child: Column(
        children: [
          _styledClimbingConditionTile("Sandstone", "Sandstone is a sedimentary rock composed of mainly sand that absorbs moisture easily when it rains.As a result, climbing this rock type while it's still wet or damp has the potential to ruin the holds (and possibly route).Please use best judgment prior to climbing.\n\nSafe: Dry rock, no rain in over 72 hours.\nCaution: Dry rock, no rain in the last 36-72 hours.\nDo not climb: Wet rock (or/and) rain within the last 36 hours."),
          _styledClimbingConditionTile("Conglomerate", "Conglomerate is a type of sedimentary rock that is comprised of rounded pebbles and sand. As a result, it's best to avoid climbing this rock type while the route is wet or damp. Furthermore, climbing wet routes leads to slippery and possible breaking of holds. \n\nSafe: Dry rock, no rain in the last 36-72 hours. \nCaution: Dry rock, no rain in the last 36 hours. \nDo not climb: Wet rock (and/or) rain in the last 36 hours."),
          _styledClimbingConditionTile("Igneous", "Igneous rock is one of the three main rock types made in the earths mantle or crust. Some examples of Igneous rock include diorite, gabbro, granite, and pegmatite.They are generally safe to climb on as the rock doesn't absorb moisture well.Be advised that wet Igneous rock is moderately slippery.\n\nSafe: Dry rock, no rain in the last 36 hours.\nCaution: Wet rock, rain in the last 36 hours."),
          _styledClimbingConditionTile("Metamorphic", "Metamorphic rock is formed when existing rocks are banded together to create a new rock. Some examples of Metamorphic rock include gneiss, quartzite, marble, and soapstone. They are generally safe to climb on as the rock doesn't absorb moisture well.\n\nSafe: Dry rock, no rain in the last 36 hours.\nCaution: Wet rock, rain in the last 36 hours."),
        ],
      ),
    );
  }

// Helper method to create a row for each climbing condition tile
  Widget _styledClimbingConditionTile(String rockType, String rockInfo) {
    return buildClimbingConditionTile(rockType, rockInfo); // Directly return the tile
  }

}
