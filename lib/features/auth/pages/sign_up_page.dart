import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/core/providers/user_provider.dart';
import 'package:upnext/core/services/supabase_auth_service.dart';
import 'package:upnext/core/widgets/custom_button.dart';
import 'package:upnext/core/widgets/custom_snackbar.dart';
import 'package:upnext/core/widgets/custom_textfield.dart';

/// Sign up page for new users to create an account.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles the signup process.
  void _signup() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate input
    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Validation Error', 'Please fill in all fields');
      return;
    }

    if (!email.contains('@')) {
      _showError('Validation Error', 'Please enter a valid email address');
      return;
    }

    if (password != confirmPassword) {
      _showError('Validation Error', 'Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _showError('Validation Error', 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create auth account
      final response = await _authService.signUpWithEmail(email, password);

      if (response.user != null) {
        // Create user record in database using UserProvider
        if (!mounted) return;
        
        await context.read<UserProvider>().createUser(
          userId: response.user!.id,
          email: email,
          username: username,
        );

        // Navigate to verification pending page
        Get.offAllNamed('/verification_pending');
      }
    } on AuthApiException catch (e) {
      debugPrint('Signup error: ${e.message}');
      if (!mounted) return;
      _showError('Signup Failed', e.message);
    } catch (e) {
      debugPrint('Signup error: $e');
      if (!mounted) return;
      _showError('Signup Failed', 'An unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar.show(
        title: title,
        message: message,
        type: SnackbarType.error,
      ),
    );
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
              
              // Title
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

              // Username field
              CustomTextfield(
                hintText: 'Username',
                controller: usernameController,
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Email field
              CustomTextfield(
                hintText: 'Email',
                controller: emailController,
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Password field
              CustomTextfield(
                hintText: 'Password',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Confirm Password field
              CustomTextfield(
                hintText: 'Confirm Password',
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Sign Up button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _signup,
                  buttonText: 'Create Account',
                  isLoading: _isLoading,
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
                    onTap: () => Get.offAllNamed('/login'),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
