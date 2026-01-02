import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upnext/services/auth_service.dart';
// FIREBASE - Imports commented out as unused during migration
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import '../providers/user_provider.dart';

import '../components/custom_button.dart';
import '../components/custom_snackbar.dart';
import '../components/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.show(
          title: 'Incomplete Fields',
          message: 'Please fill in all fields.',
          type: SnackbarType.error,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.show(
          title: 'Wrong Email Format',
          message: 'Please enter a valid email address.',
          type: SnackbarType.error,
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    // Attempt login with Supabase
    final authService = AuthService();

    try {
      final response = await authService.signInWithEmail(email, password);

      if (!mounted) return;

      
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    /* FIREBASE LOGIN - COMMENTED OUT
    try {
      final response = await AuthService.loginWithFirebase(email, password);

      if (!mounted) return;

      if (response['status'] == 'success') {
        await context.read<UserProvider>().loadUser();
        Get.offAllNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar.show(
            title: 'Login Failed',
            message: response['message'] ?? 'Please try again.',
            type: SnackbarType.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    */

    // TEMPORARY - SHOW CONSTRUCTION MESSAGE
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.show(
          title: 'App Under Construction',
          message: 'We are migrating to Supabase. Please try again later.',
          type: SnackbarType.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Welcome back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
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

              // Login Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _login,
                  buttonText: 'Sign In',
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/signup');
                    },
                    child: Text(
                      'Sign Up',
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
