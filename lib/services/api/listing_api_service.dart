import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:upnext/models/listing_model.dart';

class ListingApiService {
  final String baseUrl = 'http://10.81.6.75:8000';

  Future<List<ListingModel>> fetchListings() async {
    // TODO: fetch the listings from an API
    try {
      final response = await http.get(Uri.parse('$baseUrl/listings'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => ListingModel.fromMap(e)).toList();
      } else {
        throw Exception(
          'Failed to load listings: ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (error) {
      print('Error fetching listings <============================');
      print(error);

      return [];
    }
  }
}
