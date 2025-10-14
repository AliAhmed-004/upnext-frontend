import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upnext/pages/login_page.dart';

import 'pages/home_page.dart';
import 'providers/listing_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
