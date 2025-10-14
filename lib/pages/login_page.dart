import 'package:flutter/material.dart';

import '../components/custom_button.dart';
import '../components/custom_textfield.dart';
import '../services/login_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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

                CustomButton(
                  onPressed: () async {
                    // handle case where email or password is empty
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter email and password'),
                        ),
                      );
                      return;
                    }

                    // TODO: Handle login logic
                    // Get the email and password from the controllers
                    String email = emailController.text;
                    String password = passwordController.text;

                    // make API call for login
                    final result = await LoginService.login(email, password);

                    // show error message if login fails
                    if (!result) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login failed. Please try again.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  buttonText: 'Login',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
