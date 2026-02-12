import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/core/providers/user_provider.dart';
import 'package:upnext/core/services/supabase_auth_service.dart';
import 'package:upnext/core/widgets/custom_button.dart';
import 'package:upnext/core/widgets/custom_snackbar.dart';
import 'package:upnext/core/widgets/custom_textfield.dart';

/// Login page for existing users to sign in.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Handles the login process.
  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate input
    if (email.isEmpty || password.isEmpty) {
      _showError('Incomplete Fields', 'Please fill in all fields.');
      return;
    }

    if (!email.contains('@')) {
      _showError('Wrong Email Format', 'Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Attempt login
      await _authService.signInWithEmail(email, password);

      if (!mounted) return;

      // Load user data into provider
      await context.read<UserProvider>().loadCurrentUser();

      // Navigate to home
      Get.offAllNamed('/home');
    } on AuthApiException catch (e) {
      debugPrint('Login error: ${e.message}');
      if (!mounted) return;
      _showError('Login Failed', e.message);
    } catch (e) {
      debugPrint('Login error: $e');
      if (!mounted) return;
      _showError('Login Failed', 'An unexpected error occurred.');
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
              const SizedBox(height: 32),

              // Login button
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
                    onTap: () => Get.offAllNamed('/signup'),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
