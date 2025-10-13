import 'package:flutter/material.dart';
import 'package:upnext/pages/login_page.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const UpNext());
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
