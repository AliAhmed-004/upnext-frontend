import 'package:flutter/material.dart';
import 'package:upnext/features/listings/domain/entities/listing_model.dart';
import 'package:upnext/features/listings/data/datasources/supabase_service.dart';

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
