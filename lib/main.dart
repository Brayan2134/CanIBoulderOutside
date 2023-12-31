import 'package:flutter/material.dart';
import 'pages/weather_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  await storage.write(key: 'openWeatherMapAPIKey', value: 'eeb0f7ab19f20666b209b9027da3fe9b');
  await storage.write(key: 'googleMapsAPIKEY', value: 'AIzaSyAvM88VaGwlbJOnJesCbJo3FMyfS_4fFww');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherPage(),
      routes:{
        '/home': (context) => const WeatherPage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(), // Replace with your settings screen widget
      }
    );
  }
}
