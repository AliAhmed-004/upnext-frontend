import 'dart:io';

import 'package:flutter/material.dart';
import 'package:upnext/core/services/supabase_listing_service.dart';
import 'package:upnext/core/models/listing_model.dart';

/// Provider class that serves as the single source of truth for listing data.
/// 
/// This provider manages all listing-related operations and state, including:
/// - Fetching all listings (for home page)
/// - Fetching current user's listings
/// - Fetching booked listings
/// - Creating, booking, and deleting listings
/// 
/// Usage:
/// ```dart
/// // Fetch listings
/// await context.read<ListingProvider>().fetchListings();
/// 
/// // Access listings
/// final listings = context.watch<ListingProvider>().listings;
/// 
/// // Create a listing
/// await context.read<ListingProvider>().createListing(data, images);
/// ```
class ListingProvider extends ChangeNotifier {
  final _listingService = SupabaseListingService();

  // ============ STATE ============

  List<ListingModel> _listings = [];
  List<ListingModel> _userListings = [];
  List<ListingModel> _bookedListings = [];
  ListingModel? _selectedListing;
  
  bool _isLoading = false;
  bool _isUserListingsLoading = false;
  bool _isBookedListingsLoading = false;
  String? _error;

  // ============ GETTERS ============

  /// All listings (excluding current user's) for the home feed.
  List<ListingModel> get listings => _listings;

  /// Current user's own listings.
  List<ListingModel> get userListings => _userListings;

  /// Listings booked by the current user.
  List<ListingModel> get bookedListings => _bookedListings;

  /// The currently selected/viewed listing (with full details).
  ListingModel? get selectedListing => _selectedListing;

  /// Whether the main listings are being loaded.
  bool get isLoading => _isLoading;

  /// Whether user listings are being loaded.
  bool get isUserListingsLoading => _isUserListingsLoading;

  /// Whether booked listings are being loaded.
  bool get isBookedListingsLoading => _isBookedListingsLoading;

  /// Count of current user's listings.
  int get userListingsCount => _userListings.length;

  /// Count of booked listings.
  int get bookedListingsCount => _bookedListings.length;

  /// Any error message from the last operation.
  String? get error => _error;

  // ============ FETCH METHODS ============

  /// Fetch all listings for the home feed.
  /// 
  /// Excludes the current user's listings.
  Future<void> fetchListings({bool forceRefresh = false}) async {
    // Skip if already loaded and not forcing refresh
    if (_listings.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _listings = await _listingService.fetchAllListings();
      debugPrint('ListingProvider: Fetched ${_listings.length} listings');
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error fetching listings - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch the current user's own listings.
  Future<void> fetchUserListings() async {
    _isUserListingsLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userListings = await _listingService.fetchCurrentUserListings();
      debugPrint('ListingProvider: Fetched ${_userListings.length} user listings');
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error fetching user listings - $e');
    } finally {
      _isUserListingsLoading = false;
      notifyListeners();
    }
  }

  /// Fetch listings booked by the current user.
  Future<void> fetchBookedListings() async {
    _isBookedListingsLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookedListings = await _listingService.fetchBookedListings();
      debugPrint('ListingProvider: Fetched ${_bookedListings.length} booked listings');
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error fetching booked listings - $e');
    } finally {
      _isBookedListingsLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single listing by ID with full details (including images).
  /// 
  /// Updates [selectedListing] with the result.
  Future<ListingModel?> fetchListingById(String listingId) async {
    _error = null;

    try {
      _selectedListing = await _listingService.fetchListingById(listingId);
      notifyListeners();
      return _selectedListing;
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error fetching listing by ID - $e');
      return null;
    }
  }

  // ============ CREATE/UPDATE METHODS ============

  /// Create a new listing.
  /// 
  /// [listingData] - Map containing listing fields (title, description, etc.)
  /// [images] - List of image files to upload
  /// 
  /// Returns true on success, false on failure.
  Future<bool> createListing(
    Map<String, dynamic> listingData,
    List<File> images,
  ) async {
    _error = null;

    try {
      await _listingService.addListing(listingData, images);
      debugPrint('ListingProvider: Listing created successfully');
      
      // Refresh listings to include the new one
      await fetchUserListings();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error creating listing - $e');
      return false;
    }
  }

  /// Book a listing by ID.
  /// 
  /// Returns a map with 'status' ('success' or 'error') and 'message'.
  Future<Map<String, String>> bookListing(String listingId) async {
    _error = null;

    try {
      final result = await _listingService.bookListing(listingId);
      
      if (result['status'] == 'success') {
        // Refresh both listings and booked listings
        await Future.wait([
          fetchListings(forceRefresh: true),
          fetchBookedListings(),
        ]);
        
        // Update selected listing if it's the one being booked
        if (_selectedListing?.id == listingId) {
          await fetchListingById(listingId);
        }
      }
      
      return result;
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error booking listing - $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Cancel a booking by listing ID.
  /// 
  /// Returns a map with 'status' ('success' or 'error') and 'message'.
  Future<Map<String, String>> cancelBooking(String listingId) async {
    _error = null;

    try {
      final result = await _listingService.cancelBooking(listingId);
      
      if (result['status'] == 'success') {
        // Refresh booked listings
        await fetchBookedListings();
        
        // Update selected listing if it's the one being cancelled
        if (_selectedListing?.id == listingId) {
          await fetchListingById(listingId);
        }
      }
      
      return result;
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error cancelling booking - $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Delete a listing by ID.
  /// 
  /// Returns a map with 'status' ('success' or 'error') and 'message'.
  Future<Map<String, String>> deleteListing(String listingId) async {
    _error = null;

    try {
      final result = await _listingService.deleteListing(listingId);
      
      if (result['status'] == 'success') {
        // Remove from local lists
        _userListings.removeWhere((l) => l.id == listingId);
        _listings.removeWhere((l) => l.id == listingId);
        
        // Clear selected if it was deleted
        if (_selectedListing?.id == listingId) {
          _selectedListing = null;
        }
        
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _error = e.toString();
      debugPrint('ListingProvider: Error deleting listing - $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // ============ UTILITY METHODS ============

  /// Clear the selected listing.
  void clearSelectedListing() {
    _selectedListing = null;
    notifyListeners();
  }

  /// Clear all cached data (useful during logout).
  void clearAll() {
    _listings = [];
    _userListings = [];
    _bookedListings = [];
    _selectedListing = null;
    _error = null;
    notifyListeners();
  }
}
