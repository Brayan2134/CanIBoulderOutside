import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_model.dart'; // Assuming you have a Search model

class SearchService {
  final String apiKey;

  SearchService(this.apiKey);

  Future<Search?> search(String locationQuery) async {
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
      // Handle error, e.g., show an error message
      print('Error: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> getCurrentCity(String locationQuery) async {
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
        print('Error fetching location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null; // Return null if city is not found or in case of any error
  }


  Future<List<String>> fetchSuggestions(String input) async {
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
