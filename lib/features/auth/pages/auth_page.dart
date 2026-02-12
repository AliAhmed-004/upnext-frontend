import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/features/listings/pages/home_page.dart';
import 'package:upnext/features/auth/pages/sign_up_page.dart';
import 'package:upnext/features/auth/pages/verfication_pending_page.dart';

/// Authentication wrapper page that handles routing based on auth state.
/// 
/// Automatically redirects users to:
/// - SignUpPage if not logged in
/// - VerficationPendingPage if email not verified
/// - HomePage if fully authenticated
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // Not logged in - show signup page
        if (session == null) {
          return const SignUpPage();
        }

        final user = session.user;

        // Email not verified - show verification pending page
        if (user.emailConfirmedAt == null) {
          return const VerficationPendingPage();
        }

        // Fully authenticated - show home page
        return const HomePage();
      },
    );
  }
}
