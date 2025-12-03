import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upnext/models/listing_model.dart';
import 'package:upnext/models/user_model.dart';

class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data that the service manages
  List<ListingModel> _listings = [];

  // getters
  List<ListingModel> get listings => _listings;

  // ==========================================
  // Firestore Streams
  // ==========================================

  // Stream of all listings (excluding current user's)
  Stream<List<ListingModel>> listingsStream() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return _firestore
        .collection('listings')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => doc.data()['user_id'] != currentUserId)
              .map((doc) => ListingModel.fromMap(doc.data()))
              .toList();
        });
  }

  // ==========================================
  // Firestore Methods
  // ==========================================

  // Add User
  Future<Map<String, dynamic>> addUser(
    UserCredential? user,
    UserModel userModel,
  ) async {
    try {
      if (user == null) {
        return {'status': 'error', 'message': 'UserCredential is null'};
      }

      final uid = user.user?.uid;
      final email = user.user?.email;
      final username = userModel.username;
      final latitude = userModel.latitude;
      final longitude = userModel.longitude;

      if (uid == null || email == null) {
        return {'status': 'error', 'message': 'User ID or email is null'};
      }

      if (username.isEmpty) {
        return {'status': 'error', 'message': 'Username cannot be empty'};
      }

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'status': 'success'};
    } catch (e) {
      debugPrint('Error adding user: $e');
      return {'status': 'error', 'message': 'An unknown error occurred: $e'};
    }
  }

  // Add Listing
  Future<Map<String, dynamic>> addListing(
    Map<String, dynamic> listingData,
  ) async {
    try {
      // Create the listing and get its ID
      final result = await _firestore.collection('listings').add(listingData);
      final listingId = result.id;

      // Update the listing with the generated listingId
      await _firestore.collection('listings').doc(listingId).update({
        'id': listingId,
      });
      return {'status': 'success'};
    } catch (e) {
      debugPrint('Error adding listing: $e');
      return {'status': 'error', 'message': 'An unknown error occurred: $e'};
    }
  }

  // Fetch Listings
  Future<List<ListingModel>> fetchListings() async {
    try {
      final querySnapshot = await _firestore
          .collection('listings')
          .where(
            'user_id',
            isNotEqualTo: FirebaseAuth.instance.currentUser?.uid,
          )
          .get();

      _listings = querySnapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();

      for (var doc in querySnapshot.docs) {
        debugPrint('Fetched listing document ID: ${doc.id}');
      }

      return _listings;
    } catch (e) {
      debugPrint('Error fetching listings: $e');
      return [];
    }
  }

  // Fetch Current User's Listings
  Future<List<ListingModel>> fetchCurrentUserListings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found.');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('listings')
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      final userListings = querySnapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();

      return userListings;
    } catch (e) {
      debugPrint('Error fetching current user listings: $e');
      return [];
    }
  }

  // Fetch number of Listings of Current User
  Future<int> fetchCurrentUserListingsCount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found.');
        return 0;
      }

      final querySnapshot = await _firestore
          .collection('listings')
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching current user listings count: $e');
      return 0;
    }
  }

  // Update User Location
  Future<void> updateUserLocation(double lat, double long) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found.');
        return;
      }

      // Fetch the current user from Firestore
      final docRef = _firestore.collection('users').doc(currentUser.uid);
      final docSnapshot = await docRef.get();

      // Update the Location
      if (docSnapshot.exists) {
        await docRef.update({'latitude': lat, 'longitude': long});
        debugPrint('User location updated successfully.');
      } else {
        debugPrint('No user found with ID: ${currentUser.uid}');
      }
    } catch (e) {
      debugPrint('Error updating user location: $e');
    }
  }

  // Fetch information about the current user from Firestore
  Future<UserModel?> fetchCurrentUserDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found.');
        return null;
      }

      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        final user = UserModel.fromMap(docSnapshot.data()!);

        for (var field in docSnapshot.data()!.entries) {
          debugPrint('Fetched user data - ${field.key}: ${field.value}');
        }

        return user;
      } else {
        debugPrint('No user found with ID: ${currentUser.uid}');

        return null;
      }
    } catch (e) {
      debugPrint('Error fetching current user details: $e');

      return null;
    }
  }

  // Fetch User by ID
  Future<Map<String, dynamic>> fetchUserById(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data ?? {};
      } else {
        debugPrint('No user found with ID: $userId');
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      return {};
    }
  }

  // Fetch Listing by ID
  Future<ListingModel?> fetchListingById(String listingId) async {
    try {
      debugPrint('Fetching listing from FIRESTORE with ID: $listingId');

      final querySnapshot = await _firestore
          .collection('listings')
          .where('id', isEqualTo: listingId)
          .get();

      debugPrint('Document ID: ${querySnapshot.docs.first.id}');

      for (var field in querySnapshot.docs) {
        debugPrint('Fetched listing data: ${field.data()}');
      }

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ListingModel.fromMap(doc.data());
      } else {
        debugPrint('No listing found with ID: $listingId');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching listing by ID: $e');
      return null;
    }
  }

  // Delete Listing
  Future<Map<String, dynamic>> deleteListing(String listingId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return {'status': 'error', 'message': 'No authenticated user found'};
      }

      // First, verify the listing belongs to the current user
      final querySnapshot = await _firestore
          .collection('listings')
          .where('id', isEqualTo: listingId)
          .where('user_id', isEqualTo: currentUser.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'status': 'error',
          'message': 'Listing not found or you do not have permission to delete it'
        };
      }

      // Delete the listing
      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('listings').doc(docId).delete();

      debugPrint('Listing deleted successfully: $listingId');
      return {'status': 'success'};
    } catch (e) {
      debugPrint('Error deleting listing: $e');
      return {'status': 'error', 'message': 'An error occurred: $e'};
    }
  }

  // Book a listing
  Future<Map<String, dynamic>> bookListing(String listingId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get the listing first to verify it's available
      final querySnapshot = await _firestore
          .collection('listings')
          .where('id', isEqualTo: listingId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'success': false, 'message': 'Listing not found'};
      }

      final doc = querySnapshot.docs.first;
      final listingData = doc.data();

      // Check if user is trying to book their own listing
      if (listingData['user_id'] == currentUser.uid) {
        return {'success': false, 'message': 'You cannot book your own listing'};
      }

      // Check if listing is still active
      if (listingData['status'] != Status.active.name) {
        return {'success': false, 'message': 'This listing is no longer available'};
      }

      // Book the listing
      await _firestore.collection('listings').doc(doc.id).update({
        'status': Status.booked.name,
        'booked_by': currentUser.uid,
        'booked_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Listing booked successfully: $listingId');
      return {'success': true, 'message': 'Listing booked successfully'};
    } catch (e) {
      debugPrint('Error booking listing: $e');
      return {'success': false, 'message': 'Failed to book listing: $e'};
    }
  }

  // Cancel a booking (by the person who booked it)
  Future<Map<String, dynamic>> cancelBooking(String listingId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final querySnapshot = await _firestore
          .collection('listings')
          .where('id', isEqualTo: listingId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'success': false, 'message': 'Listing not found'};
      }

      final doc = querySnapshot.docs.first;
      final listingData = doc.data();

      // Verify the current user is the one who booked it
      if (listingData['booked_by'] != currentUser.uid) {
        return {'success': false, 'message': 'You did not book this listing'};
      }

      // Cancel the booking
      await _firestore.collection('listings').doc(doc.id).update({
        'status': Status.active.name,
        'booked_by': FieldValue.delete(),
        'booked_at': FieldValue.delete(),
      });

      debugPrint('Booking cancelled successfully: $listingId');
      return {'success': true, 'message': 'Booking cancelled successfully'};
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return {'success': false, 'message': 'Failed to cancel booking: $e'};
    }
  }

  // Fetch listings booked by current user
  Future<List<ListingModel>> fetchBookedListings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found.');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('listings')
          .where('booked_by', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: Status.booked.name)
          .get();

      final bookedListings = querySnapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();

      debugPrint('Fetched ${bookedListings.length} booked listings');
      return bookedListings;
    } catch (e) {
      debugPrint('Error fetching booked listings: $e');
      return [];
    }
  }

  // Fetch count of booked listings for current user
  Future<int> fetchBookedListingsCount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return 0;
      }

      final querySnapshot = await _firestore
          .collection('listings')
          .where('booked_by', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: Status.booked.name)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Error fetching booked listings count: $e');
      return 0;
    }
  }
}
