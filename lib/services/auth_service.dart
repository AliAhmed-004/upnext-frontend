// FIREBASE - COMMENTED OUT FOR MIGRATION TO SUPABASE
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:upnext/services/firestore_service.dart';
// import 'package:upnext/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/services/supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final supabaseService = SupabaseService();

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up (create new account) with email and password
  Future<void> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // If successful, create user record in 'Users' table
      if (response.user != null) {
        final userData = {
          'id': response.user!.id,
          'email': email,
          'username': username,
          'longitude': null,
          'latitude': null,
        };
        await supabaseService.addUser(userData);
      }
    } on AuthApiException catch (e) {
      // Handle specific Supabase auth exceptions
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      // Handle other exceptions
      throw Exception('An unexpected error occurred during sign up. $e');
    }
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
