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
