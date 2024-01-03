import 'package:flutter/material.dart';
import 'pages/weather_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildPage(WeatherPage(), 'weatherPage'),
      _buildPage(SearchPage(), 'searchPage'),
      _buildPage(SettingsPage(), 'settingsPage'),
    ];
  }

  Widget _buildPage(Widget child, String key) {
    return PageStorage(
      key: PageStorageKey<String>(key),
      bucket: bucket,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            WeatherPage(),
            SearchPage(),
            SettingsPage(),
          ],
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
