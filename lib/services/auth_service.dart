import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/services/firestore_service.dart';
import 'package:upnext/services/user_service.dart';

import '../env.dart';

class AuthService {
  // Firebase Authentication Methods
  static Future<Map<String, dynamic>> signupWithFirebase(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      debugPrint('Firebase Sign Up successful: $userCredential');

      // save the user in Firestore
      final FirestoreService firestoreService = FirestoreService();
      await firestoreService.addUser(userCredential, username);

      return {'status': 'success', 'userCredential': userCredential};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Sign Up error: $e');

      return {
        'status': 'error',
        'message': e.message ?? 'An unknown error occurred',
      };
    } catch (e) {
      debugPrint('Firebase Sign Up error: $e');
      return {'status': 'error', 'message': 'An unknown error occurred $e'};
    }
  }

  static Future<Map<String, dynamic>> loginWithFirebase(
    String email,
    String password,
  ) async {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint('Firebase Login successful: $userCredential');

      return {'status': 'success', 'userCredential': userCredential};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Login error: $e');

      return {
        'status': 'error',
        'message': e.message ?? 'An unknown error occurred',
      };
    } catch (e) {
      debugPrint('Firebase Login error: $e');
      return {'status': 'error', 'message': 'An unknown error occurred'};
    }
  }

  static Future<void> logoutFromFirebase() async {
    await FirebaseAuth.instance.signOut();
    debugPrint('User logged out from Firebase');
  }

  static Future<Map<String, dynamic>> updateUserLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    try {
      debugPrint(
        'Making API call to update user location <============================',
      );
      debugPrint('User ID: $userId');
      debugPrint('Latitude: $latitude, Longitude: $longitude');

      debugPrint('API URL: ${Env.baseUrl}${Env.updateLocationApi}');

      final response = await http.put(
        Uri.parse('${Env.baseUrl}${Env.updateLocationApi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Location update successful <============================');
        debugPrint('Response Body: ${response.body}');

        final responseBody = jsonDecode(response.body);
        final updatedUser = responseBody['user'];

        // Update the user in local storage
        await UserService.setCurrentUser({
          'user_id': updatedUser['id'],
          'username': updatedUser['username'],
          'email': updatedUser['email'],
          'created_at': updatedUser['created_at'],
          'latitude': updatedUser['latitude'],
          'longitude': updatedUser['longitude'],
        });

        debugPrint('User location updated in local storage');

        return {
          'status': 'success',
          'message': 'Location updated successfully',
          'user': updatedUser,
        };
      } else {
        debugPrint('Location update failed <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Failed to update location. Please try again.',
        };
      }
    } catch (error) {
      debugPrint(
        'Error making API call to update location <============================',
      );
      debugPrint(error.toString());
      return {
        'status': 'error',
        'message': 'An error occurred. Please try again.',
      };
    }
  }
}
