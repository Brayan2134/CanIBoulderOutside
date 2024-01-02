import 'package:flutter/material.dart';
import '../models/search_model.dart'; // Assuming you have a Search model
import 'package:boulderconds/services/search_service.dart'; // Assuming you have a SearchService
import './search_result.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SearchPage extends StatefulWidget {
  // Singleton instance
  static final SearchPage _instance = SearchPage._internal();

  factory SearchPage() {
    return _instance;
  }

  SearchPage._internal({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Search? _search;
  final _searchService = SearchService(); // Replace with your actual API key
  TextEditingController _searchController = TextEditingController();
  Future<List<String>> _suggestions = Future.value([]);
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initApiKey();
    _searchController.addListener(_onSearchChanged);
  }

  _initApiKey() async {
    String? apiKey = await _storage.read(key: 'googleMapsAPIKEY');
    if (apiKey != null) {
      _searchService.setApiKey(apiKey);
    } else {
      // Handle the case where API key is not found
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        _suggestions = _searchService.fetchSuggestions(_searchController.text.trim());
      });
    }
  }

  void _performSearch(String query) async {
    try {
      Search? searchResult = await _searchService.search(query);
      print('Search result: ${searchResult?.result}'); // Debug statement

      if (searchResult != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchResult(cityName: searchResult.result),
        ));
      } else {
        print('Search result is null'); // Debug statement
        // Optionally, show a dialog or a snackbar to inform the user
      }
    } catch (e) {
      print('Error during search: $e'); // Error handling
      // Handle the error, maybe show a dialog or a snackbar
    }
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
                  "Search Page",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white), // Change text color
                  decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: const TextStyle(color: Colors.white), // Change label text color
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white), // Change icon color
                      onPressed: () => _performSearch(_searchController.text.trim()),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FutureBuilder<List<String>>(
                    future: _suggestions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4), // Add some margin between the items
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(80, 82, 94, 1), // Background color of the container
                                borderRadius: BorderRadius.circular(10), // Optional: if you want rounded corners
                              ),
                              child: ListTile(
                                title: Text(
                                  snapshot.data![index],
                                  style: const TextStyle(color: Colors.white), // Text color
                                ),
                                onTap: () {
                                  _searchController.text = snapshot.data![index];
                                  _performSearch(snapshot.data![index]);
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text(
                        'No suggestions found.',
                        style: TextStyle(color: Colors.white), // Text color
                      ));
                    },
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
        currentIndex: 1, // Set the initial index to 1 for 'Search'
        onTap: (index) {
          // Handle navigation based on the selected index
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              // No need to navigate, already on the SearchPage
              break;
            case 2:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
