import 'package:flutter/material.dart';
import 'package:boulderconds/services/search_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/search_model.dart';
import './search_result.dart';


/// A stateful widget that provides the functionality for searching.
///
/// This widget includes a search bar and handles the search logic,
/// displaying results and suggestions.
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}




class _SearchPageState extends State<SearchPage> {
  final _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  Future<List<String>> _suggestions = Future.value([]);
  final _storage = const FlutterSecureStorage();


  /// Entry point for the searchPage.
  @override
  void initState() {
    super.initState();
    _initApiKey();
    _searchController.addListener(_onSearchChanged);
  }


  /// Initializes the API key for the search service from secure storage.
  _initApiKey() async {
    String? apiKey = await _storage.read(key: 'googleMapsAPIKEY');
    if (apiKey != null) {
      _searchService.setApiKey(apiKey);
    } else {
      // Handle the case where API key is not found
    }
  }


  /// Fetch city/country suggestions from searchService as the user types in the text field.
  void _onSearchChanged() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        _suggestions = _searchService.fetchSuggestions(_searchController.text.trim());
      });
    }
  }


  /// Take the city and country from the user and
  /// take the user to the searchResult page.
  ///
  /// Additionally, send the city and country information from the text field to
  /// the searchResult page, so that it could be processed.
  ///
  /// [query] is a string that contains the city and country of which weather information
  /// will be gathered from.
  void _performSearch(String query) async {
    try {
      Search? searchResult = await _searchService.search(query);

      if (searchResult != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchResult(cityName: searchResult.result),
        ));
      } else {
        throw ('Search result is null'); // Debug statement
        // Optionally, show a dialog or a snack bar to inform the user??
      }
    } catch (e) {
      throw ('Error during search: $e'); // Error handling
      // Handle the error, maybe show a dialog or a snack bar??
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
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
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(80, 82, 94, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  snapshot.data![index],
                                  style: const TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white),
                      ));
                    },
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    // The dispose method is called when this widget is removed from the tree permanently.
    // It is a good place to release resources that this widget holds.

    // Remove the listener from the search controller.
    // This is necessary to prevent memory leaks, as the listener might hold onto resources
    // that would not be disposed of otherwise.
    _searchController.removeListener(_onSearchChanged);

    // Dispose of the search controller itself.
    // Controllers should always be disposed of in the dispose method to release any resources
    // they hold and to unregister them from any listeners. This is crucial for performance and
    // to prevent memory leaks.
    _searchController.dispose();

    // Always call super.dispose() at the end of the method to ensure that any inherited
    // dispose logic is executed. Failing to call super.dispose() can lead to resource leaks.
    super.dispose();
  }


}