import 'package:flutter/material.dart';
import 'package:upnext/core/models/user_model.dart';
import 'package:upnext/core/services/supabase_auth_service.dart';
import 'package:upnext/core/services/supabase_user_service.dart';

/// Provider class that serves as the single source of truth for user data.
/// 
/// This provider manages the current user's state, handles authentication-related
/// user operations, and provides easy access to user data throughout the app.
/// 
/// Usage:
/// ```dart
/// // Access user data
/// final user = context.read<UserProvider>().currentUser;
/// 
/// // Check if user is loaded
/// if (context.watch<UserProvider>().isLoggedIn) { ... }
/// ```
class UserProvider extends ChangeNotifier {
  final _userService = SupabaseUserService();
  final _authService = SupabaseAuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ============ GETTERS ============

  /// The currently loaded user, or null if not loaded/logged in.
  UserModel? get currentUser => _currentUser;

  /// Whether the provider is currently loading user data.
  bool get isLoading => _isLoading;

  /// The current user's ID, or null if not logged in.
  String? get userId => _currentUser?.id;

  /// The current user's email, or null if not logged in.
  String? get userEmail => _currentUser?.email;

  /// The current user's username, or null if not logged in.
  String? get username => _currentUser?.username;

  /// Whether a user is currently loaded.
  bool get isLoggedIn => _currentUser != null;

  /// Whether the current user has location data.
  bool get hasLocation => _currentUser?.hasLocation ?? false;

  /// Any error message from the last operation, or null if no error.
  String? get error => _error;

  // ============ METHODS ============

  /// Load the current user's data from the database.
  /// 
  /// This should be called after successful authentication to populate
  /// the user data. Typically called in main.dart or after login.
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.fetchCurrentUser();
      if (_currentUser != null) {
        debugPrint('UserProvider: Loaded user ${_currentUser!.email}');
      } else {
        debugPrint('UserProvider: No user found');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider: Error loading user - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the current user's location.
  /// 
  /// [latitude] - The new latitude value.
  /// [longitude] - The new longitude value.
  Future<bool> updateLocation(double latitude, double longitude) async {
    if (_currentUser == null) {
      _error = 'No user logged in';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.updateUserLocation(latitude, longitude);
      
      // Update local user model
      _currentUser = _currentUser!.copyWith(
        latitude: latitude,
        longitude: longitude,
      );
      
      debugPrint('UserProvider: Location updated to ($latitude, $longitude)');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider: Error updating location - $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new user in the database after sign up.
  /// 
  /// [userId] - The auth user's ID from Supabase Auth.
  /// [email] - The user's email address.
  /// [username] - The user's chosen username.
  Future<bool> createUser({
    required String userId,
    required String email,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = UserModel(
        id: userId,
        email: email,
        username: username,
      );

      await _userService.addUser(newUser);
      _currentUser = newUser;
      
      debugPrint('UserProvider: Created new user $email');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider: Error creating user - $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch another user's data by their ID.
  /// 
  /// This is useful for displaying other users' info (e.g., listing creators).
  /// Does NOT update the current user state.
  Future<UserModel?> fetchUserById(String userId) async {
    try {
      return await _userService.fetchUserById(userId);
    } catch (e) {
      debugPrint('UserProvider: Error fetching user by ID - $e');
      return null;
    }
  }

  /// Clear the current user data (used during logout).
  Future<void> clearUser() async {
    await _authService.signOut();
    _currentUser = null;
    _error = null;
    notifyListeners();
    debugPrint('UserProvider: User cleared (logged out)');
  }

  /// Refresh the current user's data from the database.
  Future<void> refreshUser() async {
    await loadCurrentUser();
  }
}
