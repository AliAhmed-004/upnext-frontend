import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/models/listing_model.dart';

class SupabaseService {
  // This class will handle Supabase Database related operations
  // The operations include CRUD operations for listings and users

  final supabase = Supabase.instance.client;

  // Users Table
  final userTable = Supabase.instance.client.from('Users');
  // Listings Table
  final listingsTable = Supabase.instance.client.from('Listings');

  /*
   *
   * USERS TABLE OPERATIONS
   * 
   */
  // Fetch current user's id
  String? getCurrentUserId() {
    final user = supabase.auth.currentUser;
    return user?.id;
  }

  // Fetch user data from table
  Future<Map<String, dynamic>?> fetchUserData(String email) async {
    try {
      final userData = await userTable.select().eq('email', email).single();

      return userData;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  // Fetch user data by id
  Future<Map<String, dynamic>?> fetchUserDataById(String userId) async {
    try {
      final userData = await userTable.select().eq('id', userId).single();

      return userData;
    } catch (e) {
      debugPrint('Error fetching user data by id: $e');
      return null;
    }
  }

  // Add user to Supabase
  Future<void> addUser(Map<String, dynamic> userData) async {
    await userTable.insert(userData);
  }

  // Update user location
  Future<void> updateUserLocation(double latitude, double longitude) async {
    final email = supabase.auth.currentUser?.email;

    if (email == null) {
      return;
    }

    await userTable
        .update({'latitude': latitude, 'longitude': longitude})
        .eq('email', email);
  }

  /*
   *
   * LISTINGS TABLE OPERATIONS
   * 
   */
  // Add listing to Supabase
  Future<void> addListing(Map<String, dynamic> listingData, List<File> images) async {
    // Insert listing data into Listings table
    await listingsTable.insert(listingData);

    // Upload images to Supabase Storage
    for (var image in images) {
      final fileName = image.path.split('/').last;
      final storagePath = 'listings/${listingData['id']}/$fileName';

      await supabase.storage.from('listing-images').upload(storagePath, image);
    }
  }

  // Fetch all listings except current user's from Lisrings table
  Future<List<ListingModel>> fetchAllListings() async {
    // Get current user's id from Users table
    final currentUserEmail = supabase.auth.currentUser?.email;
    if (currentUserEmail == null) {
      return [];
    }

    final currentUserData = await fetchUserData(currentUserEmail);
    if (currentUserData == null) {
      return [];
    }

    final currentUserId = currentUserData['id'];

    // Fetch all listings except current user's
    final listings = await listingsTable.select().neq('user_id', currentUserId);

    // Convert listings to List<ListingModel>
    return listings.map((listing) => ListingModel.fromMap(listing)).toList();
  }

  // Fetch listing by id
  Future<ListingModel?> fetchListingById(String listingId) async {
    try {
      final listingData = await listingsTable
          .select()
          .eq('id', listingId)
          .single();

      return ListingModel.fromMap(listingData);
    } catch (e) {
      debugPrint('Error fetching listing by id: $e');
      return null;
    }
  }

  // Fetch current user's listings
  Future<List<ListingModel>> fetchCurrentUserListings() async {
    // Get currentUserId
    final userId = getCurrentUserId();

    if (userId == null) {
      return [];
    }

    final rawUserListings = await listingsTable
        .select('*')
        .eq('user_id', userId);

    final userListings = rawUserListings
        .map<ListingModel>((listing) => ListingModel.fromMap(listing))
        .toList();

    return userListings;
  }

  // Book listing by id
  Future<Map<String, String>> bookListing(String listingId) async {
    try {
      await listingsTable
          .update({
            'status': Status.booked.name,
            'booked_at': DateTime.now().toIso8601String(),
            'booked_by': getCurrentUserId(),
          })
          .eq('id', listingId);
      return {'status': 'success', 'message': 'Listing booked successfully'};
    } catch (e) {
      debugPrint('Error booking listing: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Fetch booked listings for current user
  Future<List<ListingModel>> fetchBookedListings() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      return [];
    }
    final rawBookedListings = await listingsTable
        .select('*')
        .eq('booked_by', userId);

    final bookedListings = rawBookedListings
        .map<ListingModel>((listing) => ListingModel.fromMap(listing))
        .toList();

    return bookedListings;
  }

  // Cancel booking by listing id
  Future<Map<String, String>> cancelBooking(String listingId) async {
    try {
      await listingsTable
          .update({
            'status': Status.active.name,
            'booked_at': null,
            'booked_by': null,
          })
          .eq('id', listingId);
      return {'status': 'success', 'message': 'Booking cancelled successfully'};
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Delete listing by id
  Future<Map<String, String>> deleteListing(String listingId) async {
    try {
      await listingsTable.delete().eq('id', listingId);
      return {'status': 'success'};
    } catch (e) {
      debugPrint('Error deleting listing: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
