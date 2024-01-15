import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../services/weather_services.dart';


/// A stateful widget for displaying and managing application settings.
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}



class _SettingsPageState extends State<SettingsPage> {
  String currentUnit = 'Metric'; // Default value
  final List<String> units = ['Imperial', 'Metric'];
  final SettingsService settingsService = SettingsService();
  final WeatherService _weatherService = WeatherService(); // Local instance


  /// Entry point for settingsPage.
  @override
  void initState() {
    super.initState();
    _loadUnitType();
  }


  /// Handles changes to the unit type.
  ///
  /// When a new unit is selected, this method updates the state and persists the choice using [SettingsService].
  /// [newUnit] The new unit type selected by the user.
  void _onUnitChanged(String newUnit) {
    // TODO: Implement the logic that should happen when the unit changes
    // For example, update the WeatherService settings or notify other parts of the app

    setState(() {
      currentUnit = newUnit;
    });
    // Update the unit type in SettingsService
    settingsService.updateUnitTypeFromSettings(currentUnit.toLowerCase());
  }


  /// Loads the current unit type from settings.
  ///
  /// Retrieves the saved unit type from [SettingsService] and updates the state accordingly.
  void _loadUnitType() async {
    String savedUnit = await settingsService.getCurrentUnitType();
    setState(() {
      currentUnit = savedUnit == 'metric' ? 'Metric' : 'Imperial';
    });
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
    );
  }


  /// Creates a row for a single setting.
  ///
  /// [label] The label of the setting.
  /// [settingWidget] The widget used to change the setting.
  /// Returns a widget displaying the setting row.
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


  /// Retrieves the temperature scale based on the current unit.
  ///
  /// Returns 'Fahrenheit' for Imperial and 'Celsius' for Metric units.

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


  /// Retrieves the wind speed scale based on the current unit.
  ///
  /// Returns 'Mph' for Imperial and 'Km/hr' for Metric units.
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