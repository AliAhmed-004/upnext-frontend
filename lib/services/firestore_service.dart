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
        debugPrint(
          'Type of createdAt: ${docSnapshot.data()?['createdAt']?.runtimeType}',
        );
        final user = UserModel.fromMap(docSnapshot.data()!);

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
}
