import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/core/models/user_model.dart';

/// Service class handling all Supabase user-related database operations.
/// This includes CRUD operations for the Users table.
class SupabaseUserService {
  final _supabase = Supabase.instance.client;

  /// Reference to the Users table.
  SupabaseQueryBuilder get _userTable => _supabase.from('Users');

  /// Returns the currently authenticated user's ID.
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Returns the currently authenticated user's email.
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  /// Fetch user data by email.
  /// 
  /// Returns a [UserModel] if found, null otherwise.
  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final userData = await _userTable.select().eq('email', email).single();
      return UserModel.fromMap(userData);
    } catch (e) {
      debugPrint('Error fetching user data by email: $e');
      return null;
    }
  }

  /// Fetch user data by user ID.
  /// 
  /// Returns a [UserModel] if found, null otherwise.
  Future<UserModel?> fetchUserById(String userId) async {
    try {
      final userData = await _userTable.select().eq('id', userId).single();
      return UserModel.fromMap(userData);
    } catch (e) {
      debugPrint('Error fetching user data by id: $e');
      return null;
    }
  }

  /// Fetch the currently authenticated user's data.
  /// 
  /// Returns a [UserModel] if the user is authenticated and found, null otherwise.
  Future<UserModel?> fetchCurrentUser() async {
    final email = currentUserEmail;
    if (email == null) return null;
    return await fetchUserByEmail(email);
  }

  /// Add a new user to the database.
  /// 
  /// The [user] parameter should contain all required user fields.
  Future<void> addUser(UserModel user) async {
    await _userTable.insert(user.toMap());
  }

  /// Update user location by email.
  /// 
  /// Updates the latitude and longitude for the currently authenticated user.
  Future<void> updateUserLocation(double latitude, double longitude) async {
    final email = currentUserEmail;
    if (email == null) {
      debugPrint('Cannot update location: No authenticated user');
      return;
    }

    await _userTable
        .update({'latitude': latitude, 'longitude': longitude})
        .eq('email', email);
  }

  /// Update user profile data.
  /// 
  /// Updates the provided fields for the user with the given [userId].
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _userTable.update(updates).eq('id', userId);
  }
}
