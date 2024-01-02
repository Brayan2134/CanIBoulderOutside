import 'package:flutter/material.dart';
import 'pages/weather_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const WeatherPage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );

  }
}
