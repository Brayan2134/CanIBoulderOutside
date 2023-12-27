import 'package:flutter/material.dart';
import '../models/search_model.dart'; // Assuming you have a Search model
import 'package:boulderconds/services/search_service.dart'; // Assuming you have a SearchService

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Screen'),
      ),
      body: const Center(
        child: Text('Hello', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
