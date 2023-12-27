import 'package:flutter/material.dart';
import '../models/search_model.dart'; // Assuming you have a Search model
import 'package:boulderconds/services/search_service.dart'; // Assuming you have a SearchService
import './search_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Search? _search;
  final _searchService = SearchService('AIzaSyAvM88VaGwlbJOnJesCbJo3FMyfS_4fFww'); // Replace with your actual API key
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize your data or perform any setup here
  }

  // Function to perform the search
  void _performSearch() async {
    String query = _searchController.text.trim();

    // Call your search service to get results based on the query
    Search? searchResult = await _searchService.search(query);

    // Navigate to the new HelloScreen
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SearchResult(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    // Display search results or appropriate UI based on _search
                    if (_search != null)
                      Text('Search Result: ${_search!.result}'),
                    // Add your search page UI components here

                    // For example:
                    // TextField(
                    //   controller: _searchController,
                    //   decoration: InputDecoration(labelText: 'Search'),
                    // ),
                    // ElevatedButton(
                    //   onPressed: _performSearch,
                    //   child: Text('Search'),
                    // ),
                  ],
                ),
              ),
            ),
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
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
            // No need to navigate, already on the Search page
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}
