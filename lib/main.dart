import 'package:flutter/material.dart';

import 'pages/weather_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';

/*
* UPDATE API KEY MANUALLY:
*
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

  Future<void> updateOpenWeatherMapApiKey() async {
    const storage = FlutterSecureStorage();
    const newApiKey = 'YOUR_NEW_API_KEY'; // Replace with your new API key
    await storage.write(key: "openWeatherMapAPIKey", value: newApiKey);
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized
    await updateOpenWeatherMapApiKey(); // Update the API key

    runApp(MyApp()); // Replace MyApp with the name of your app widget
}
* */


/// The entry point of the application.
void main(){
  runApp(MyApp());
}


/// The main application widget.
///
/// This widget is the root of the application and controls the primary navigation.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}



/// State for [MyApp].
///
/// This class holds the state for the [MyApp] widget, including the current selected index
/// and the list of pages to display.
class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    WeatherPage(),
    SearchPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud),
              label: 'Weather',
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }


  /// Handles navigation bar item taps.
  ///
  /// Updates the state to reflect the selected index [index].
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


}