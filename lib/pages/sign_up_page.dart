import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upnext/services/auth_service.dart';

import '../components/custom_button.dart';
import '../components/custom_textfield.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    void signup() async {
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please fill in all fields',
          backgroundColor: Colors.red[200],
        );
        return;
      }

      if (!email.contains('@')) {
        Get.snackbar(
          'Validation Error',
          'Please enter a valid email address',
          backgroundColor: Colors.red[200],
        );
        return;
      }

      if (password != confirmPassword) {
        // Show error message
        print('Passwords do not match');
        Get.snackbar(
          'Validation Error',
          'Passwords do not match',
          backgroundColor: Colors.red[200],
        );
        return;
      }

      final response = await AuthService.signupWithFirebase(
        email,
        password,
        username,
      );

      final status = response['status'];
      final message = response['message'];

      if (status != 'success') {
        // Show error message
        Get.snackbar(
          'Sign Up Failed',
          '$message',
          backgroundColor: Colors.red[200],
        );
        return;
      }

      // Navigate to Home Page and clear all previous routes
      Get.offAllNamed('/home');

      // if (response['status'] == 'success') {
      //   // Ensure provider has latest user from storage
      //   await context.read<UserProvider>().loadUser();
      //   // Navigate to Home Page and clear all previous routes
      //   Get.offAllNamed('/home');
      // } else {
      //   // Show error message
      //   Get.snackbar(
      //     'Sign Up Failed',
      //     response['message'] ?? 'Please try again.',
      //     backgroundColor: Colors.red[200],
      //   );
      // }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.recycling_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Create account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join our community today',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 48),

              // Username Text Field
              CustomTextfield(
                hintText: 'Username',
                controller: usernameController,
                obscureText: false,
              ),
              const SizedBox(height: 20),

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
                child: CustomButton(
                  onPressed: signup,
                  buttonText: 'Create Account',
                ),
              ),
              const SizedBox(height: 32),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Login Page
                      Get.back();
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
