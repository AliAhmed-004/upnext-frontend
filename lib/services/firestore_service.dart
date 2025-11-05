import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upnext/models/listing_model.dart';

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
    String username,
  ) async {
    try {
      if (user == null) {
        return {'status': 'error', 'message': 'UserCredential is null'};
      }

      final uid = user.user?.uid;
      final email = user.user?.email;

      if (uid == null || email == null) {
        return {'status': 'error', 'message': 'User ID or email is null'};
      }

      if (username.isEmpty) {
        return {'status': 'error', 'message': 'Username cannot be empty'};
      }

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {'status': 'success'};
    } catch (e) {
      debugPrint('Error adding user: $e');
      return {'status': 'error', 'message': 'An unknown error occurred: $e'};
    }
  }

  // Add Listing
  Future<Map<String, dynamic>> addListing(ListingModel listing) async {
    try {
      _firestore.collection('listings').add(listing.toMap());

      return {'status': 'success'};
    } catch (e) {
      debugPrint('Error adding listing: $e');
      return {'status': 'error', 'message': 'An unknown error occurred: $e'};
    }
  }
}
