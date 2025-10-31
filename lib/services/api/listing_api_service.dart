import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/env.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/user_service.dart';

class ListingApiService {
  Future<List<ListingModel>> fetchListings() async {
    final user = await UserService.getCurrentUser();
    if (user == null) {
      throw Exception('User not found');
    }
    final userId = user['user_id'];
    try {
      // Replace with actual endpoint
      final response = await http.get(
        Uri.parse('${Env.baseUrl}${Env.getListingsApi}?user_id=$userId'),
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

  // Fetch listing by user ID
  Future<List<ListingModel>> fetchListingsByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}${Env.getListingsByUser}?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => ListingModel.fromMap(e)).toList();
      } else {
        throw Exception(
          'Failed to load listings for user $userId: ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (error) {
      debugPrint(
        'Error fetching listings by user ID <============================',
      );
      debugPrint(error.toString());

      return [];
    }
  }

  // Create a new listing
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
      } else if (response.statusCode == 400) {
        debugPrint("Bad Request Creating Listing: ${response.reasonPhrase}");
        return {'status': 400, 'message': "Bad Request Creating Listing"};
      } else if (response.statusCode == 500) {
        debugPrint("Server Error Creating Listing: ${response.reasonPhrase}");
        return {'status': 500, 'message': "Server Error Creating Listing"};
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

  Future<int> getNumberOfListings(String userId) async {
    // get the number of listings for a specific user
    try {
      final response = await http.get(
        Uri.parse(
          '${Env.baseUrl}${Env.getNumberOfListingsOfUser}?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Number of listings for user $userId: ${data['count']}');

        return data['count'];
      } else {
        debugPrint(
          'Failed to get number of listings: ${response.statusCode}: ${response.reasonPhrase}',
        );

        return 0;
      }
    } catch (error) {
      debugPrint(
        'Error fetching number of listings <============================',
      );
      debugPrint(error.toString());

      return 0;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      final response = await http.delete(
        Uri.parse("${Env.baseUrl}${Env.deleteListing}/$listingId"),
      );

      if (response.statusCode == 200) {
        return true;
      }
      debugPrint(
        "Failed to delete listing. Status code: ${response.statusCode}",
      );
      return false;
    } catch (e) {
      debugPrint('Error deleting listing <============================');
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> bookListing(String listingId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse('${Env.baseUrl}${Env.bookListing}/$listingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'listing_id': listingId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true || data['status'] == 200;
      } else {
        debugPrint(
          'Failed to book listing: ${response.statusCode}: ${response.reasonPhrase}',
        );
        return false;
      }
    } catch (error) {
      debugPrint('Error booking listing <============================');
      debugPrint(error.toString());
      return false;
    }
  }
}
