import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:upnext/firebase_options.dart';
import 'package:upnext/pages/auth_page.dart';
import 'package:upnext/pages/create_listing_page.dart';
import 'package:upnext/pages/item_location_picker_page.dart';
import 'package:upnext/pages/login_page.dart';
import 'package:upnext/pages/sign_up_page.dart';
import 'package:upnext/pages/profile_page.dart';
import 'package:upnext/theme_provider.dart';
import 'package:upnext/app_themes.dart';

import 'pages/home_page.dart';
import 'pages/manage_listings_page.dart';
import 'pages/user_listings_page.dart';
import 'providers/listing_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
      ],
      child: const UpNext(),
    ),
  );
}

class UpNext extends StatelessWidget {
  const UpNext({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      title: 'Up Next',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/auth',
      getPages: [
        GetPage(name: '/auth', page: () => AuthPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/signup', page: () => const SignUpPage()),
        GetPage(name: '/create_listing', page: () => const CreateListingPage()),
        GetPage(
          name: '/pick_location',
          page: () => const ItemLocationPickerPage(),
        ),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/user_listings', page: () => const UserListingsPage()),
        GetPage(
          name: '/manage_listings',
          page: () => const ManageListingsPage(),
        ),
      ],
    );
  }
}
