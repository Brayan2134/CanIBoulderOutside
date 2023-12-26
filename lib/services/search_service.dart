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

      return Search(result: 'Location found: $formattedAddress');
    } else {
      // Handle error, e.g., show an error message
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}
