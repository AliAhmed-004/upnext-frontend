import 'package:flutter/material.dart';

import '../components/custom_button.dart';
import '../components/custom_textfield.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Login function
    void login() async {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      final response = await AuthService.login(email, password);

      if (response['status'] == 'success') {
        // Navigate to Home Page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message']!)));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Icon(Icons.recycling_rounded, size: 100, color: Colors.blue),
                Text(
                  'Up Next',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),

                // Email Text Field
                CustomTextfield(
                  hintText: 'Email',
                  controller: emailController,
                  obscureText: false,
                ),
                SizedBox(height: 16),

                // Password Text Field
                CustomTextfield(
                  hintText: 'Password',
                  controller: passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // dont have an account? Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Sign Up Page
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Login Button
                SizedBox(height: 24),

                CustomButton(onPressed: login, buttonText: 'Login'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
