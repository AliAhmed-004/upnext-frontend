import 'package:flutter/material.dart';
import 'package:upnext/services/auth_service.dart';

import '../components/custom_button.dart';
import '../components/custom_textfield.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    void signup() async {
      final password = passwordController.text.trim();
      final email = emailController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        // Show error message
        print('Passwords do not match');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
        return;
      }

      final response = await AuthService.signUp(email, password);

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

                // Cofirm Password Text Field
                CustomTextfield(
                  hintText: 'Confirm Password',
                  controller: confirmPasswordController,
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Already have an account? Login Instead
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Sign Up Page
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Log in',
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

                CustomButton(onPressed: signup, buttonText: 'Sign Up'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
