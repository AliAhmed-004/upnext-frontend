import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/custom_button.dart';
import '../components/custom_textfield.dart';
import '../services/auth_service.dart';
import '../env.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController serverIpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the server IP field with the current base URL
    serverIpController.text = Env.baseUrl;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    serverIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Login function
    void login() async {
      String serverUrl = serverIpController.text.trim();
      if (serverUrl.isNotEmpty) {
        // Update the base URL before making the request
        await Env.setBaseUrl(serverUrl);
      }

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
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
      
      final response = await AuthService.login(email, password);

      if (!mounted)
        return; // Check if widget is still mounted before using context

      if (response['status'] == 'success') {
        // Navigate to Home Page and clear all previous routes
        Get.offAllNamed('/home');
      } else {
        // Show error message
        Get.snackbar(
          'Login Failed',
          response['message'] ?? 'Please try again.',
          backgroundColor: Colors.red[200],
        );
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
                'Welcome back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
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

              // Server IP Text Field
              CustomTextfield(
                hintText: 'Server IP (optional)',
                controller: serverIpController,
                obscureText: false,
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(onPressed: login, buttonText: 'Sign In'),
              ),
              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/signup');
                    },
                    child: const Text(
                      'Sign Up',
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
