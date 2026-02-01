import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/core/services/supabase_storage_service.dart';
import 'package:upnext/core/services/supabase_user_service.dart';
import 'package:upnext/features/listings/models/listing_model.dart';

/// Service class handling all Supabase listing-related database operations.
/// This includes CRUD operations for the Listings table.
class SupabaseListingService {
  final _supabase = Supabase.instance.client;
  final _storageService = SupabaseStorageService();
  final _userService = SupabaseUserService();

  /// Reference to the Listings table.
  SupabaseQueryBuilder get _listingsTable => _supabase.from('Listings');

  /// Returns the currently authenticated user's ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Add a new listing to the database.
  /// 
  /// [listingData] - Map containing the listing fields.
  /// [images] - List of image files to upload for this listing.
  Future<void> addListing(
    Map<String, dynamic> listingData,
    List<File> images,
  ) async {
    // Insert listing data into Listings table
    final listing = await _listingsTable.insert(listingData).select().single();

    // Upload images to Supabase Storage
    if (images.isNotEmpty) {
      await _storageService.uploadListingImages(listing['id'], images);
    }
  }

  /// Fetch all listings except the current user's.
  /// 
  /// Returns listings in descending order of creation date.
  Future<List<ListingModel>> fetchAllListings() async {
    // Get current user's ID
    final currentUser = await _userService.fetchCurrentUser();
    if (currentUser == null) {
      debugPrint('Cannot fetch listings: No authenticated user');
      return [];
    }

    // Fetch all listings except current user's in descending order of created_at
    final listings = await _listingsTable
        .select()
        .neq('user_id', currentUser.id)
        .order('created_at', ascending: false);

    // Convert to List<ListingModel>
    return listings.map((listing) => ListingModel.fromMap(listing)).toList();
  }

  /// Fetch a single listing by ID with its images.
  /// 
  /// Returns [ListingModel] with image URLs populated, or null if not found.
  Future<ListingModel?> fetchListingById(String listingId) async {
    try {
      final listingData = await _listingsTable
          .select()
          .eq('id', listingId)
          .single();

      debugPrint('Fetching images for listing ID: $listingId');

      // Fetch images for the listing
      final imageUrls = await _storageService.fetchListingImageUrls(listingId);
      listingData['image_urls'] = imageUrls;

      debugPrint('Listing fetched with ${imageUrls.length} images');

      return ListingModel.fromMap(listingData);
    } catch (e) {
      debugPrint('Error fetching listing by id: $e');
      return null;
    }
  }

  /// Fetch all listings created by the current user.
  /// 
  /// Returns listings in descending order of creation date.
  Future<List<ListingModel>> fetchCurrentUserListings() async {
    final userId = _currentUserId;
    if (userId == null) {
      debugPrint('Cannot fetch user listings: No authenticated user');
      return [];
    }

    final rawUserListings = await _listingsTable
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rawUserListings
        .map<ListingModel>((listing) => ListingModel.fromMap(listing))
        .toList();
  }

  /// Book a listing by ID.
  /// 
  /// Sets the listing status to 'booked' and records who booked it.
  /// Returns a map with 'status' ('success' or 'error') and 'message'.
  Future<Map<String, String>> bookListing(String listingId) async {
    try {
      await _listingsTable
          .update({
            'status': Status.booked.name,
            'booked_at': DateTime.now().toIso8601String(),
            'booked_by': _currentUserId,
          })
          .eq('id', listingId);
      return {'status': 'success', 'message': 'Listing booked successfully'};
    } catch (e) {
      debugPrint('Error booking listing: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Fetch all listings booked by the current user.
  /// 
  /// Returns listings in descending order of booking date.
  Future<List<ListingModel>> fetchBookedListings() async {
    final userId = _currentUserId;
    if (userId == null) {
      debugPrint('Cannot fetch booked listings: No authenticated user');
      return [];
    }

    final rawBookedListings = await _listingsTable
        .select('*')
        .eq('booked_by', userId)
        .order('booked_at', ascending: false);

    return rawBookedListings
        .map<ListingModel>((listing) => ListingModel.fromMap(listing))
        .toList();
  }

  /// Cancel a booking by listing ID.
  /// 
  /// Resets the listing status to 'active' and clears booking info.
  /// Returns a map with 'status' ('success' or 'error') and 'message'.
  Future<Map<String, String>> cancelBooking(String listingId) async {
    try {
      await _listingsTable
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

  /// Delete a listing by ID.
  /// 
  /// Also deletes associated images from storage.
  /// Returns a map with 'status' ('success' or 'error') and 'message'.
  Future<Map<String, String>> deleteListing(String listingId) async {
    try {
      // Delete images first
      await _storageService.deleteListingImages(listingId);
      
      // Delete the listing
      await _listingsTable.delete().eq('id', listingId);

      // TODO: Delete images from storage if the listing had any


      return {'status': 'success', 'message': 'Listing deleted successfully'};
    } catch (e) {
      debugPrint('Error deleting listing: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
