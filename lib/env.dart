import 'package:shared_preferences/shared_preferences.dart';

class Env {
  static String _baseUrl = 'http://10.238.222.95:8000';

  static String get baseUrl => _baseUrl;

  static Future<void> setBaseUrl(String url) async {
    if (url.isEmpty) return;

    // Save the URL to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', url);

    _baseUrl = url;
  }

  static Future<void> initializeBaseUrl() async {
    // Load the URL from persistent storage if it exists
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('base_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _baseUrl = savedUrl;
    }
  }

  // Listings Endpoints
  static final String getListingsApi = "/listing/get_all";
  static final String createListingApi = "/listing/create";
  static final String getListingById = "/listing/get_by_id";

  // Auth Enpoints
  static final String loginApi = "/users/login";
  static final String signUpApi = "/users/signup";
}
