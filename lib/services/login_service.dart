import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env.dart';

class LoginService {
  static Future<bool> login(String email, String password) async {
    try {
      debugPrint('Making API call to log in <============================');
      print('Username: $email');
      print('Password: $password');

      final response = await http.post(
        Uri.parse('${Env.baseUrl}${Env.loginApi}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print('Login successful <============================');
        print('Response Body: ${response.body}');
        return true;
      } else {
        print('Login failed <============================');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error making API call to log in <============================');
      print(error);
      return false;
    }
  }
}
