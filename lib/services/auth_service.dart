import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:upnext/services/database_service.dart';

import '../env.dart';

class AuthService {
  static Future<Map<String, String>> signUp(
    String email,
    String password,
    String createdAt,
  ) async {
    try {
      debugPrint('Making API call to sign up <============================');
      debugPrint('Username: $email');
      debugPrint('Password: $password');

      debugPrint('API URL: ${Env.baseUrl}${Env.signUpApi}');

      final response = await http.post(
        Uri.parse('${Env.baseUrl}${Env.signUpApi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'created_at': createdAt,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Sign Up successful <============================');
        debugPrint('Response Body: ${response.body}');

        final responseBody = jsonDecode(response.body);
        final user = responseBody['user'];

        // save the user in Database
        final dbHelper = DatabaseService();
        await dbHelper.insertUser({
          'user_id': user['id'],
          'username': user['username'],
          'email': user['email'],
          'created_at': user['created_at'],
          'latitude': user['latitude'],
          'longitude': user['longitude'],
        });

        return {'status': 'success', 'message': 'Sign Up successful'};
      } else {
        debugPrint('Sign Up failed <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        final responseBody = jsonDecode(response.body);
        return {
          'status': 'error',
          'message': responseBody['detail'],
        };
      }
    } catch (error) {
      debugPrint(
        'Error making API call to sign up <============================',
      );
      debugPrint(error.toString());
      return {
        'status': 'error',
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  static Future<Map<String, String>> login(
    String email,
    String password,
  ) async {
    try {
      debugPrint('Making API call to log in <============================');
      debugPrint('Username: $email');
      debugPrint('Password: $password');

      debugPrint('API URL: ${Env.baseUrl}${Env.loginApi}');

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
          'user_id': user['id'],
          'username': user['username'],
          'email': user['email'],
          'created_at': user['created_at'],
          'latitude': user['latitude'],
          'longitude': user['longitude'],
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

  static Future<Map<String, dynamic>> updateUserLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    try {
      debugPrint(
        'Making API call to update user location <============================',
      );
      debugPrint('User ID: $userId');
      debugPrint('Latitude: $latitude, Longitude: $longitude');

      debugPrint('API URL: ${Env.baseUrl}${Env.updateLocationApi}');

      final response = await http.put(
        Uri.parse('${Env.baseUrl}${Env.updateLocationApi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Location update successful <============================');
        debugPrint('Response Body: ${response.body}');

        final responseBody = jsonDecode(response.body);
        final updatedUser = responseBody['user'];

        // Update the user in Database
        final dbHelper = DatabaseService();
        await dbHelper.updateUser({
          'user_id': updatedUser['id'],
          'username': updatedUser['username'],
          'email': updatedUser['email'],
          'created_at': updatedUser['created_at'],
          'latitude': updatedUser['latitude'],
          'longitude': updatedUser['longitude'],
        });

        debugPrint('User location updated in local database');

        return {
          'status': 'success',
          'message': 'Location updated successfully',
          'user': updatedUser,
        };
      } else {
        debugPrint('Location update failed <============================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Failed to update location. Please try again.',
        };
      }
    } catch (error) {
      debugPrint(
        'Error making API call to update location <============================',
      );
      debugPrint(error.toString());
      return {
        'status': 'error',
        'message': 'An error occurred. Please try again.',
      };
    }
  }
}
