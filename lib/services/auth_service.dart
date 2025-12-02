import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:upnext/models/user_model.dart';
import 'package:upnext/services/firestore_service.dart';

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

      // create a UserModel
      final user = UserModel(
        username: username,
        email: email,
        latitude: null,
        longitude: null,
      );

      // save the user in Firestore
      final FirestoreService firestoreService = FirestoreService();
      await firestoreService.addUser(userCredential, user);

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
}
