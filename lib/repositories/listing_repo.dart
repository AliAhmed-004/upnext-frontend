import 'package:flutter/material.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/firestore_service.dart';

class ListingRepo {
  final FirestoreService _firestoreService = FirestoreService();

  Future<List<ListingModel>> getListings() async {
    try {
      debugPrint('Fetching listings from FirestoreService using repo');
      final listings = await _firestoreService.fetchListings();
      return listings;
    } catch (error) {
      debugPrint('Error in ListingRepo getListings: $error');
      return [];
    }
  }

  Future<List<ListingModel>> getListingsByUserId(String userId) async {
    try {
      // Fetch from Firestore for current user's listings
      final listings = await _firestoreService.fetchCurrentUserListings();
      return listings;
    } catch (error) {
      debugPrint('Error in ListingRepo getListingsByUserId: $error');
      return [];
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      final result = await _firestoreService.deleteListing(listingId);
      return result['status'] == 'success';
    } catch (error) {
      debugPrint('Error in ListingRepo deleteListing: $error');
      return false;
    }
  }
}
