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
  Future<List<String>> _suggestions = Future.value([]);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
                  onPressed: () => _performSearch(_searchController.text.trim()),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _suggestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index]),
                        onTap: () {
                          _searchController.text = snapshot.data![index];
                          _performSearch(snapshot.data![index]);
                        },
                      );
                    },
                  );
                }
                return Center(child: Text('No suggestions found.'));
              },
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
