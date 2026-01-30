import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerficationPendingPage extends StatelessWidget {
  const VerficationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_empty,
                size: 100,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'We have sent a verification email to your registered email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please check your email and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  Get.offAllNamed('/login');
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
