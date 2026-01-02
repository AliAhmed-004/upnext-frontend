import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/helper/helper_methods.dart';
import 'package:upnext/models/user_model.dart';
import 'package:upnext/services/auth_service.dart';
import 'package:provider/provider.dart';
// FIREBASE - COMMENTED OUT FOR MIGRATION
// import 'package:upnext/services/firestore_service.dart';
import 'package:upnext/theme_provider.dart';

import '../components/custom_snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  String? userAddress;

  int? numberOfListings;
  int? numberOfBookedItems;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _fetchNumberOfListings();
    _fetchNumberOfBookedItems();
  }

  String _initialsFrom(String? nameOrEmail) {
    if (nameOrEmail == null || nameOrEmail.trim().isEmpty) return '?';
    final String base = nameOrEmail.contains('@')
        ? nameOrEmail.split('@').first
        : nameOrEmail;
    final parts = base.trim().split(RegExp(r"\s+|[_\-.]"));
    final letters = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]);
    return letters.join().toUpperCase();
  }

  // Get user from database
  void _getUserInfo() async {
    setState(() => isLoading = true);
    // FIREBASE - COMMENTED OUT
    // final fetchedUser = await FirestoreService().fetchCurrentUserDetails();
    final UserModel? fetchedUser = null; // Placeholder during migration

    // debug print all fields of fetchedUser
    debugPrint('Fetched user data:');
    if (fetchedUser != null) {
      debugPrint('Username: ${fetchedUser.username}');
      debugPrint('Email: ${fetchedUser.email}');
      debugPrint('Latitude: ${fetchedUser.latitude}');
      debugPrint('Longitude: ${fetchedUser.longitude}');
      debugPrint('CreatedAt: ${fetchedUser.createdAt}');
    }

    if (fetchedUser == null) {
      debugPrint('No user data found.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      user = fetchedUser;
    });

    // If user has location, get address
    if (user!.latitude != null && user!.longitude != null) {
      final address = await getAddressFromLatLng(
        fetchedUser.latitude!,
        fetchedUser.longitude!,
      );
      setState(() {
        userAddress = address;
        isLoading = false;
      });
    }
  }

  // Check if location is available
  bool _hasLocation() {
    final dynamic latRaw = user!.latitude;
    final dynamic longRaw = user!.longitude;
    final double? lat = latRaw is num
        ? latRaw.toDouble()
        : double.tryParse('${latRaw ?? ''}');
    final double? long = longRaw is num
        ? longRaw.toDouble()
        : double.tryParse('${longRaw ?? ''}');
    return lat != null && long != null;
  }

  // Get current location and update user
  Future<void> _updateLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar.show(
              title: 'Location Services Disabled',
              message:
                  'Please enable location services in your device settings.',
              type: SnackbarType.error,
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackbar.show(
                title: 'Permission Denied',
                message:
                    'Location permission is required to update your location.',
                type: SnackbarType.error,
              ),
            );
          }
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar.show(
              title: 'Permission Permanently Denied',
              message:
                  'Please enable location permissions in your device settings.',
              type: SnackbarType.error,
            ),
          );
        }
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
      );

      debugPrint(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      // FIREBASE - Update user location in Firestore - COMMENTED OUT
      // await FirestoreService().updateUserLocation(
      //   position.latitude,
      //   position.longitude,
      // );

      // Get address from coordinates
      final address = await getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        userAddress = address;
      });

      if (mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar.show(
            title: 'Error Updating Location',
            message: e.toString(),
            type: SnackbarType.success,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get number of listings
  void _fetchNumberOfListings() async {
    // FIREBASE - COMMENTED OUT
    // final count = await FirestoreService().fetchCurrentUserListingsCount();
    final count = 0; // Placeholder during migration
    if (mounted) {
      setState(() {
        numberOfListings = count;
      });
    }
  }

  // Get number of booked items
  void _fetchNumberOfBookedItems() async {
    // FIREBASE - COMMENTED OUT
    // final count = await FirestoreService().fetchBookedListingsCount();
    final count = 0; // Placeholder during migration
    if (mounted) {
      setState(() {
        numberOfBookedItems = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final username = user!.username;
    final email = user!.email;
    final createdAt = user!.createdAt!.toDate();

    final formattedDate = formatIsoDate(createdAt.toIso8601String());

    final bool hasLocation = _hasLocation();

    final themeProvider = Provider.of<ThemeProvider>(context);
    ThemeMode mode = themeProvider.themeMode;

    final List<(String, ThemeMode)> themeChoices = [
      ('System', ThemeMode.system),
      ('Light', ThemeMode.light),
      ('Dark', ThemeMode.dark),
    ];

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
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      child: Text(
                        _initialsFrom(username),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Theme dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: DropdownButton<ThemeMode>(
                        value: mode,
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
                  ),
                  Center(
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(email),
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.event_outlined),
                            title: const Text('Joined'),
                            subtitle: Text(formattedDate),
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: const Text('Address'),
                            subtitle: Text(
                              userAddress ??
                                  (isLoading
                                      ? 'Loading...'
                                      : 'Location not set yet'),
                            ),
                            trailing: !hasLocation
                                ? IconButton(
                                    icon: const Icon(Icons.my_location),
                                    onPressed: isLoading
                                        ? null
                                        : _updateLocation,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(top: 16.0),
                    child: ListTile(
                      leading: const Icon(Icons.list_alt_outlined),
                      title: const Text('Number of Listings'),
                      subtitle: Text(
                        numberOfListings != null
                            ? '$numberOfListings'
                            : 'Loading...',
                      ),
                      trailing: CustomButton(
                        onPressed: () {
                          Get.toNamed('/manage_listings');
                        },
                        buttonText: "Manage",
                      ),
                    ),
                  ),

                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(top: 16.0),
                    child: ListTile(
                      leading: const Icon(Icons.bookmark_outlined),
                      title: const Text('Booked Items'),
                      subtitle: Text(
                        numberOfBookedItems != null
                            ? '$numberOfBookedItems'
                            : 'Loading...',
                      ),
                      trailing: CustomButton(
                        onPressed: () {
                          Get.toNamed('/booked_listings');
                        },
                        buttonText: "View",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (!hasLocation)
                    CustomButton(
                      onPressed: isLoading ? null : _updateLocation,
                      buttonText: isLoading
                          ? 'Getting location...'
                          : 'Set My Location',
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    onPressed: () {
                      // AuthService.logoutFromFirebase();
                      Get.offAllNamed('/login');
                    },
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
}
