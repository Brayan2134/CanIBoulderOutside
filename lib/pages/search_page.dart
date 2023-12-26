import 'package:flutter/material.dart';
import '../models/search_model.dart'; // Assuming you have a Search model
import 'package:boulderconds/services/search_service.dart'; // Assuming you have a SearchService

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Search? _search;
  final _searchService = SearchService(); // Replace with your actual search service

  @override
  void initState() {
    super.initState();
    // Initialize your data or perform any setup here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
      ),
      body: const Column(
        children: [
          // Your search page UI components go here
          Text("HelloWorld"),
        ],
      ),
    );
  }
}
