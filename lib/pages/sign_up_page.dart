import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        // Navigate to Home Page and clear all previous routes
        Get.offAllNamed('/home');
      } else {
        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message']!)));
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // App Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join our community today',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 48),

              // Email Text Field
              CustomTextfield(
                hintText: 'Email',
                controller: emailController,
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Password Text Field
              CustomTextfield(
                hintText: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password Text Field
              CustomTextfield(
                hintText: 'Confirm Password',
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(onPressed: signup, buttonText: 'Create Account'),
              ),
              const SizedBox(height: 32),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Login Page
                      Get.back();
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
