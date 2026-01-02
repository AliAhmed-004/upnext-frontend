// FIREBASE - COMMENTED OUT FOR MIGRATION TO SUPABASE
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:upnext/services/firestore_service.dart';
// import 'package:upnext/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // FIREBASE AUTHENTICATION METHODS - COMMENTED OUT FOR MIGRATION
  /*
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

      // determine what the error message is (user not found, wrong password, etc.)
      if (e.code == 'user-not-found') {
        return {
          'status': 'error',
          'message': 'No user found for that email.',
        };
      } else if (e.code == 'invalid-credential') {
        return {
          'status': 'error',
          'message': 'Wrong password provided for that user.',
        };
      } 

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
  */

  // TEMPORARY PLACEHOLDER METHODS FOR MIGRATION
  // static Future<Map<String, dynamic>> signupWithFirebase(
  //   String email,
  //   String password,
  //   String username,
  // ) async {
  //   return {'status': 'error', 'message': 'App is under construction. Please try again later.'};
  // }

  // static Future<Map<String, dynamic>> loginWithFirebase(
  //   String email,
  //   String password,
  // ) async {
  //   return {'status': 'error', 'message': 'App is under construction. Please try again later.'};
  // }

  // static Future<void> logoutFromFirebase() async {
  //   debugPrint('Logout disabled during migration');
  // }
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Sign out from Supabase
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // get user email
  String? getUserEmail() {
    final session = _supabase.auth.currentSession;
    return session?.user.email;
  }
}
