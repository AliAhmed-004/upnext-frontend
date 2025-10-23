import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/env.dart';
import 'package:upnext/models/listing_model.dart';

class ListingApiService {
  Future<List<ListingModel>> fetchListings() async {
    // fetch the listings from an API
    try {
      // Replace with actual endpoint
      final response = await http.get(
        Uri.parse('${Env.baseUrl}${Env.getListingsApi}'),
      );

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

  Future<Map<String, dynamic>> createListing(ListingModel listing) async {
    // create a new listing via an API
    try {
      debugPrint("Creating Listing: ${listing.toMap()}");

      final response = await http.post(
        Uri.parse('${Env.baseUrl}${Env.createListingApi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(listing.toMap()),
      );

      if (response.statusCode == 200) {
        return {'status': 200, 'message': "Listing Created Successfully"};
      } else {
        debugPrint("Error Creating Listing: ${response.reasonPhrase}");
        return {'status': 'error', 'message': "Error Creating Listing"};
      }
    } catch (error) {
      debugPrint('Error creating listing <============================');
      debugPrint(error.toString());
      return {'status': 'error'};
    }
  }
}
