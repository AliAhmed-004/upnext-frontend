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
  // Add user to Supabase
  Future<void> addUser(Map<String, dynamic> userData) async {
    await userTable.insert(userData);
  }

  // Fetch current user email
  String? getCurrentUserEmail() {
    final user = supabase.auth.currentUser;
    return user?.email;
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

  /*
   *
   * LISTINGS TABLE OPERATIONS
   * 
   */
  // Add listing to Supabase
  Future<void> addListing(Map<String, dynamic> listingData) async {
    await listingsTable.insert(listingData);
  }

  // Fetch all listings except current user's from Lisrings table
  Future<List<ListingModel>> fetchAllListings() async {
    // Get current user's id from Users table
    final currentUserEmail = getCurrentUserEmail();
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
}

