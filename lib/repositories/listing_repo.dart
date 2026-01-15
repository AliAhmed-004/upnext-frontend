import 'package:flutter/material.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/services/supabase_service.dart';
// FIREBASE - COMMENTED OUT FOR MIGRATION
// import 'package:upnext/services/firestore_service.dart';

class ListingRepo {
  final supabaseService = SupabaseService();

  Future<List<ListingModel>> getListings() async {
    try {
      debugPrint('Fetching listings from SupabaseService using repo');

      final listings = await supabaseService.fetchAllListings();
      return listings;
    } catch (error) {
      debugPrint('Error in ListingRepo getListings: $error');
      return [];
    }
  }

  Future<List<ListingModel>> getListingsByUserId(String userId) async {
    /* FIREBASE - COMMENTED OUT
    try {
      // Fetch from Firestore for current user's listings
      final listings = await _firestoreService.fetchCurrentUserListings();
      return listings;
    } catch (error) {
      debugPrint('Error in ListingRepo getListingsByUserId: $error');
      return [];
    }
    */
    return [];
  }

  Future<List<ListingModel>> getListingsByCategory(String category) async {
    try {
      debugPrint('Fetching listings for category: $category');
      final listings = await supabaseService.fetchListingsByCategory(category);
      return listings;
    } catch (error) {
      debugPrint('Error in ListingRepo getListingsByCategory: $error');
      return [];
    }
  }

  Future<bool> deleteListing(String listingId) async {
    /* FIREBASE - COMMENTED OUT
    try {
      final result = await _firestoreService.deleteListing(listingId);
      return result['status'] == 'success';
    } catch (error) {
      debugPrint('Error in ListingRepo deleteListing: $error');
      return false;
    }
    */
    return false;
  }
}
