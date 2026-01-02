import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/pages/home_page.dart';
import 'package:upnext/pages/sign_up_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Loading State
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: const Center(child: CircularProgressIndicator()));
          }

          // Check if session is valid
          final session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            // User is logged in
            return const HomePage();
          } else {
            // User is not logged in
            return const SignUpPage();
          }
          
        },
    );
  }
}
