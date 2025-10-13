import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const UpNext());
}

class UpNext extends StatelessWidget {
  const UpNext({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Up Next', home: const HomePage());
  }
}
