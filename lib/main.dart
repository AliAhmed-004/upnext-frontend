import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/env.dart';
import 'package:upnext/pages/create_listing_page.dart';
import 'package:upnext/pages/login_page.dart';
import 'package:upnext/pages/sign_up_page.dart';
import 'package:upnext/pages/splash_screen.dart';

import 'pages/home_page.dart';
import 'providers/listing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize base URL from storage
  await Env.initializeBaseUrl();

  // add providers
  runApp(
    ChangeNotifierProvider(
      create: (_) => ListingProvider(),
      child: const UpNext(),
    ),
  );
}

class UpNext extends StatelessWidget {
  const UpNext({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Up Next',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1F2937),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
        '/create_listing': (context) => const CreateListingPage(),
      },
    );
  }
}
