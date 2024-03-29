import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/search_model.dart';


/// A service class for handling search and geocoding operations.
class SearchService {
  String? apiKey; // Grabs the apiKey stored in shared preferences and stores it as a string.

  SearchService();

  /// Sets the API key for the search service.
  ///
  /// [key] The API key as a [String].
  setApiKey(String key) {
    apiKey = key;
  }


  /// Searches for a location based on a given query.
  ///
  /// This method performs a search using the provided [locationQuery] and
  /// returns the first result as a [Search] object.
  ///
  /// [locationQuery] The query string for the location search.
  /// Returns a [Future] that resolves to a [Search] object or null if the search fails.
  /// Throws an [Exception] if the API key is not initialized.
  Future<Search?> search(String locationQuery) async {

    if (apiKey == null) {
      throw Exception('search_service search: GOOGLE MAPS API KEY IS NOT INITIALIZED');
    }

    final apiKeyParam = 'key=$apiKey';
    final endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?$apiKeyParam&address=$locationQuery';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      // Assuming the first result contains the necessary information
      final firstResult = decodedResponse['results'][0];
      final formattedAddress = firstResult['formatted_address'];

      return Search(result: formattedAddress);
    } else {
      return null;
    }
  }


  /// Retrieves the city name based on a given location query.
  ///
  /// This method performs a geocoding operation using the [locationQuery] and
  /// returns the city name if found.
  ///
  /// [locationQuery] The query string for the geocoding operation.
  /// Returns a [Future] that resolves to a [String] representing the city name or null if not found.
  /// Throws an [Exception] if the API key is not initialized.
  Future<String?> getCurrentCity(String locationQuery) async {

    if (apiKey == null) {
      throw Exception('search_service getCurrentCity: GOOGLE MAPS API KEY IS NOT INITIALIZED');
    }

    final apiKeyParam = 'key=$apiKey';
    final endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?$apiKeyParam&address=$locationQuery';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final results = decodedResponse['results'];

        if (results.isNotEmpty) {
          // Iterate through each address component in the first result
          for (var component in results[0]['address_components']) {
            // Check if the component type is 'locality' which usually contains the city name
            if (component['types'].contains('locality')) {
              return component['long_name']; // This should be the city name only
            }
          }
        }
      } else {
        throw('Error fetching location: ${response.statusCode}');
      }
    } catch (e) {
      throw('Error: $e');
    }
    return null; // Return null if city is not found or in case of any error
  }


  /// Fetches autocomplete suggestions for a given input.
  ///
  /// This method fetches autocomplete suggestions for the provided [input] string.
  ///
  /// [input] The input string for which to fetch suggestions.
  /// Returns a [Future] that resolves to a [List<String>] of suggestions.
  /// Throws an [Exception] if the API key is not initialized.
  Future<List<String>> fetchSuggestions(String input) async {

    if (apiKey == null) {
      throw Exception('search_service fetchSuggestions: GOOGLE MAPS API KEY IS NOT INITIALIZED');
    }

    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&key=$apiKey';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // Properly cast the map operation to return a List<String>
        return (result['predictions'] as List)
            .map<String>((p) => p['description'].toString())
            .toList();
      }
    }
    return []; // Return an empty list on failure
  }


}