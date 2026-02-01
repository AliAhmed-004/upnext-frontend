import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:upnext/core/providers/user_provider.dart';
import 'package:upnext/core/theme/theme_provider.dart';
import 'package:upnext/core/utils/helper_methods.dart';
import 'package:upnext/core/widgets/custom_button.dart';
import 'package:upnext/core/widgets/custom_snackbar.dart';
import 'package:upnext/features/listings/providers/listing_provider.dart';

/// Profile page displaying user information and app settings.
/// 
/// Shows user details, location, listing counts, and provides
/// navigation to manage listings and booked items.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userAddress;
  bool isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load user data and listing counts.
  void _loadData() {
    Future.microtask(() async {
      final listingProvider = context.read<ListingProvider>();
      
      // Load user listings and booked listings for counts
      await Future.wait([
        listingProvider.fetchUserListings(),
        listingProvider.fetchBookedListings(),
      ]);

      // Load user address if location is available
      final user = context.read<UserProvider>().currentUser;
      if (user?.hasLocation == true && mounted) {
        final address = await getAddressFromLatLng(
          user!.latitude,
          user.longitude,
        );
        setState(() => userAddress = address);
      }
    });
  }

  /// Update the user's location.
  Future<void> _updateLocation() async {
    setState(() => isUpdatingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location Services Disabled', 
            'Please enable location services in your device settings.');
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permission Denied', 
              'Location permission is required to update your location.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Permission Permanently Denied', 
            'Please enable location permissions in your device settings.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      // Update location through provider
      final success = await context.read<UserProvider>().updateLocation(
        position.latitude,
        position.longitude,
      );

      if (success && mounted) {
        // Get address from coordinates
        final address = await getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        setState(() => userAddress = address);

        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar.show(
            title: 'Location Updated',
            message: 'Your location has been updated successfully.',
            type: SnackbarType.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showError('Error Updating Location', e.toString());
    } finally {
      if (mounted) {
        setState(() => isUpdatingLocation = false);
      }
    }
  }

  void _showError(String title, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar.show(
        title: title,
        message: message,
        type: SnackbarType.error,
      ),
    );
  }

  /// Sign out and clear all data.
  void _signOut() async {
    await context.read<UserProvider>().clearUser();
    context.read<ListingProvider>().clearAll();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final listingProvider = context.watch<ListingProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    final user = userProvider.currentUser;

    // Show loading if user not loaded
    if (userProvider.isLoading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  
                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Theme dropdown
                  _buildThemeSelector(themeProvider),
                  
                  // Username
                  Center(
                    child: Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // User info card
                  _buildUserInfoCard(user),
                  const SizedBox(height: 16),
                  
                  // Listings card
                  _buildListingsCard(listingProvider.userListingsCount),
                  
                  // Booked items card
                  _buildBookedItemsCard(listingProvider.bookedListingsCount),
                  const SizedBox(height: 16),
                  
                  // Location button (if no location set)
                  if (!user.hasLocation)
                    CustomButton(
                      onPressed: isUpdatingLocation ? null : _updateLocation,
                      buttonText: isUpdatingLocation 
                          ? 'Getting location...' 
                          : 'Set My Location',
                    ),
                  const SizedBox(height: 12),
                  
                  // Sign out button
                  CustomButton(
                    onPressed: _signOut,
                    buttonText: 'Sign Out',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    final themeChoices = [
      ('System', ThemeMode.system),
      ('Light', ThemeMode.light),
      ('Dark', ThemeMode.dark),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: DropdownButton<ThemeMode>(
          value: themeProvider.themeMode,
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          underline: Container(height: 0),
          onChanged: (ThemeMode? value) {
            if (value != null) themeProvider.setThemeMode(value);
          },
          items: themeChoices.map((pair) {
            return DropdownMenuItem<ThemeMode>(
              value: pair.$2,
              child: Row(
                children: [
                  Icon(
                    pair.$2 == ThemeMode.system
                        ? Icons.phone_android
                        : pair.$2 == ThemeMode.light
                            ? Icons.light_mode
                            : Icons.dark_mode,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(pair.$1),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(user.email),
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Address'),
              subtitle: Text(
                userAddress ?? (user.hasLocation ? 'Loading...' : 'Location not set yet'),
              ),
              trailing: user.hasLocation
                  ? IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: isUpdatingLocation ? null : _updateLocation,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsCard(int count) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16.0),
      child: ListTile(
        leading: const Icon(Icons.list_alt_outlined),
        title: const Text('Number of Listings'),
        subtitle: Text('$count'),
        trailing: CustomButton(
          onPressed: () => Get.toNamed('/manage_listings'),
          buttonText: "Manage",
        ),
      ),
    );
  }

  Widget _buildBookedItemsCard(int count) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 16.0),
      child: ListTile(
        leading: const Icon(Icons.bookmark_outlined),
        title: const Text('Booked Items'),
        subtitle: Text('$count'),
        trailing: CustomButton(
          onPressed: () => Get.toNamed('/booked_listings'),
          buttonText: "View",
        ),
      ),
    );
  }
}
