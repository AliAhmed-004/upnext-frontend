import 'package:flutter/material.dart';
import 'package:upnext/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get userId => _user?['user_id'] as String?;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    _user = await UserService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    _user = user;
    notifyListeners();
    await UserService.setCurrentUser(user);
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
    await UserService.clearCurrentUser();
  }
}
