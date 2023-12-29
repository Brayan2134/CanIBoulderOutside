import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentUnit = 'Metric'; // Default value
  final List<String> units = ['Imperial', 'Metric'];
  final SettingsService settingsService = SettingsService();

  void _onUnitChanged(String newUnit) {
    setState(() {
      currentUnit = newUnit;
    });
    // Update the unit type in SettingsService
    settingsService.updateUnitTypeFromSettings(currentUnit);
  }

  void _loadUnitType() async {
    String savedUnit = await settingsService.getCurrentUnitType();
    setState(() {
      currentUnit = savedUnit == 'metric' ? 'Metric' : 'Imperial';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUnitType();
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
                ],
              ),
            ),
          ),

          Column(
            children: <Widget>[
              AppBar(
                title: const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Unit Type Row
                        settingsRow(
                          "Unit Type",
                          DropdownButton<String>(
                            value: currentUnit,
                            icon: const Icon(Icons.arrow_downward, color: Colors.white,),
                            elevation: 16,
                            style: const TextStyle(color: Colors.white),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                currentUnit = newValue!;
                                _onUnitChanged(currentUnit);
                              });
                            },
                            items: units.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  color: Colors.transparent,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Temperature Scale Row
                        settingsRow(
                          "Temperature Scale",
                          Text(
                            getTemperatureScale(),
                            style: const TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),


                        // Wind Speed Scale Row
                        settingsRow(
                          "Wind Speed Scale",
                          Text(
                            getWindSpeedScale(),
                            style: const TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
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
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation based on the selected index
          switch (index) {
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
      ), // Your existing bottom navigation bar code
    );
  }


  Widget settingsRow(String label, Widget settingWidget) {
    return Container(
      padding: const EdgeInsets.all(8), // Padding inside the container
      margin: const EdgeInsets.only(bottom: 15), // Margin between each settings row
      decoration: BoxDecoration(
        color: const Color.fromRGBO(80, 82, 94, 1), // Background color for the container
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
          Expanded(
            flex: 1,
            child: settingWidget,
          ),
        ],
      ),
    );
  }


  String getTemperatureScale() {
    switch (currentUnit) {
      case 'Imperial':
        return 'Fahrenheit';
      case 'Metric':
        return 'Celsius';
      default:
        return 'Celsius'; // Default case
    }
  }

  String getWindSpeedScale() {
    switch (currentUnit) {
      case 'Imperial':
        return 'Mph';
      case 'Metric':
        return 'Km/hr';
      default:
        return 'Celsius'; // Default case
    }
  }
}