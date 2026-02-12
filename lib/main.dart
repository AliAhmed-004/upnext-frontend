import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upnext/core/constants/env.dart';

// Core imports
import 'package:upnext/core/theme/theme_provider.dart';
import 'package:upnext/core/theme/app_themes.dart';
import 'package:upnext/core/providers/user_provider.dart';

// Feature imports
import 'package:upnext/features/auth/pages/auth_page.dart';
import 'package:upnext/features/auth/pages/login_page.dart';
import 'package:upnext/features/auth/pages/sign_up_page.dart';
import 'package:upnext/features/auth/pages/verfication_pending_page.dart';
import 'package:upnext/features/listings/pages/home_page.dart';
import 'package:upnext/features/listings/pages/create_listing_page.dart';
import 'package:upnext/features/listings/pages/item_location_picker_page.dart';
import 'package:upnext/features/listings/pages/manage_listings_page.dart';
import 'package:upnext/features/listings/pages/booked_listings_page.dart';
import 'package:upnext/features/listings/pages/user_listings_page.dart';
import 'package:upnext/core/providers/listing_provider.dart';
import 'package:upnext/features/profile/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        // Theme provider for app-wide theme management
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // User provider - single source of truth for user data
        ChangeNotifierProvider(create: (_) => UserProvider()..loadCurrentUser()),
        
        // Listing provider - single source of truth for listings
        ChangeNotifierProvider(create: (_) => ListingProvider()),
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
        GetPage(name: '/auth', page: () => const AuthPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/signup', page: () => const SignUpPage()),
        GetPage(name: '/create_listing', page: () => const CreateListingPage()),
        GetPage(name: '/pick_location', page: () => const ItemLocationPickerPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/user_listings', page: () => const UserListingsPage()),
        GetPage(name: '/manage_listings', page: () => const ManageListingsPage()),
        GetPage(name: '/booked_listings', page: () => const BookedListingsPage()),
        GetPage(name: '/verification_pending', page: () => const VerficationPendingPage()),
      ],
    );
  }
}
