import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentUnit = 'Metric'; // Default value
  final List<String> units = ['Imperial', 'Metric', 'Standard'];

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

                          // Add your "Unit Type" and DropdownButton here
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Unit Type",
                                  style: TextStyle(fontSize: 16.0, color: Colors.white), // Adjust style as needed
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: DropdownButton<String>(
                                  value: currentUnit,
                                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.white),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      currentUnit = newValue!;
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


}
