import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/pages/home_page.dart';
import 'package:upnext/pages/sign_up_page.dart';
import 'package:upnext/pages/verfication_pending_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // Logged out or invalid session
        if (session == null) {
          return const SignUpPage();
        }

        final user = session.user;

        // Email not verified
        if (user.emailConfirmedAt == null) {
          return const VerficationPendingPage();
        }

        // Fully authenticated
        return const HomePage();
      },
    );
  }
}
