import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/services/database_service.dart';

import '../env.dart';

class LoginService {
  static Future<Map<String, String>> login(
    String email,
    String password,
  ) async {
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
        final user = responseData['user'];

        // Save the user in Database
        final dbHelper = DatabaseService();

        await dbHelper.insertUser({
          'username': user['username'],
          'email': user['email'],
        });

        debugPrint('User: $user saved in local database');

        return {'status': 'success', 'message': 'Login successful'};
      } else if (response.statusCode == 401) {
        debugPrint('Login failed: Unauthorized <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Reason: ${response.reasonPhrase}');
        return {'status': 'error', 'message': 'Incorrect password'};
      } else if (response.statusCode == 500) {
        debugPrint('Login failed: Server Error <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Reason: ${response.reasonPhrase}');
        return {
          'status': 'error',
          'message': 'Server error. Please try again later.',
        };
      } else if (response.statusCode == 404) {
        debugPrint(
          'Login failed: User not Found <============================',
        );
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Reason: ${response.reasonPhrase}');
        return {'status': 'error', 'message': 'Please Sign up first'};
      } else {
        debugPrint('Login failed <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Login failed. Please try again.',
        };
      }
    } catch (error) {
      debugPrint(
        'Error making API call to log in <============================',
      );
      debugPrint(error.toString());
      return {
        'status': 'error',
        'message': 'An error occurred. Please try again.',
      };
    }
  }
}
