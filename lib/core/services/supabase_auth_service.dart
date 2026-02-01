import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class handling all Supabase authentication operations.
/// This includes sign in, sign up, sign out, and session management.
class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns the currently authenticated user's email, or null if not logged in.
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  /// Returns the currently authenticated user's ID, or null if not logged in.
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Returns true if a user is currently authenticated.
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with email and password.
  /// 
  /// Throws [AuthException] if sign in fails.
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up (create new account) with email and password.
  /// 
  /// Returns the [AuthResponse] containing the new user.
  /// Throws [AuthException] if sign up fails.
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
