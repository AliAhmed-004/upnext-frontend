import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../env.dart';

class LoginService {
  static Future<bool> login(String email, String password) async {
    try {
      debugPrint('Making API call to log in <============================');
      debugPrint('Username: $email');
      debugPrint('Password: $password');

      final response = await http.post(
        Uri.parse('${Env.baseUrl}${Env.loginApi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        debugPrint('Login successful <============================');
        debugPrint('Response Body: ${response.body}');

        // extract user id from response body
        final responseData = jsonDecode(response.body);
        final userId = responseData['user']['user_id'];
        debugPrint('User ID: $userId');

        // save this user id to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);

        debugPrint('User ID saved to SharedPreferences');

        return true;
      } else {
        debugPrint('Login failed <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        return false;
      }
    } catch (error) {
      debugPrint(
        'Error making API call to log in <============================',
      );
      debugPrint(error.toString());
      return false;
    }
  }
}
