import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:upnext/components/custom_button.dart';
import 'package:upnext/services/auth_service.dart';
import 'package:upnext/services/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final dbHelper = DatabaseService();
  Map<String, dynamic> user = {};
  String? userAddress;
  bool isLoadingLocation = false;

  String _initialsFrom(String? nameOrEmail) {
    if (nameOrEmail == null || nameOrEmail.trim().isEmpty) return '?';
    final String base = nameOrEmail.contains('@')
        ? nameOrEmail.split('@').first
        : nameOrEmail;
    final parts = base.trim().split(RegExp(r"\s+|[_\-.]"));
    final letters = parts.where((p) => p.isNotEmpty).take(2).map((p) => p[0]);
    return letters.join().toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  // Get user from database
  void _getUser() async {
    final fetchedUser = await dbHelper.getUsers();
    final currentUser = fetchedUser[0];

    setState(() {
      user = currentUser;
    });

    // Fetch address after user (and their coordinates) are loaded
    final dynamic latRaw = currentUser['latitude'];
    final dynamic longRaw = currentUser['longitude'];

    final double? lat = latRaw is num
        ? latRaw.toDouble()
        : double.tryParse('${latRaw ?? ''}');
    final double? long = longRaw is num
        ? longRaw.toDouble()
        : double.tryParse('${longRaw ?? ''}');

    await _getAddressFromLatLng(lat, long);
  }

  // Get user address from latitude and longitude
  Future<void> _getAddressFromLatLng(double? lat, double? long) async {
    try {
      if (lat == null || long == null) {
        setState(() {
          userAddress = 'Location not available';
        });
        return;
      }
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';

        setState(() {
          userAddress = address;
        });
      }

      debugPrint('Address: $userAddress');
    } catch (e) {
      debugPrint('Error in getting address: $e');

      setState(() {
        userAddress = 'Unable to get address';
      });
    }
  }

  // Check if location is available
  bool _hasLocation() {
    final dynamic latRaw = user['latitude'];
    final dynamic longRaw = user['longitude'];
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
      isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          Get.snackbar(
            'Location Services Disabled',
            'Please enable location services in your device settings.',
            backgroundColor: Colors.red[200],
          );
        }
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            Get.snackbar(
              'Permission Denied',
              'Location permission is required to update your location.',
              backgroundColor: Colors.red[200],
            );
          }
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permissions are permanently denied. Please enable them in settings.',
              ),
            ),
          );
        }
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      // Update location on backend
      final result = await AuthService.updateUserLocation(
        user['user_id'],
        position.latitude,
        position.longitude,
      );

      if (result['status'] == 'success') {
        // Refresh user data from database
        _getUser();
        Get.snackbar(
          'Location Updated',
          'Your location has been updated successfully!',
          backgroundColor: Colors.green[200],
        );
      } else {
        Get.snackbar(
          'Location Update Failed',
          result['message'] ?? 'Failed to update location',
          backgroundColor: Colors.red[200],
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        Get.snackbar(
          'Error Updating Location',
          'Error: ${e.toString()}',
          backgroundColor: Colors.red[200],
        );
      }
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = user['username'];
    final email = user['email'];
    final createdAt = user['created_at'];
    final bool hasLocation = _hasLocation();

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
                        _initialsFrom(username ?? email),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      username ?? 'User',
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
                            subtitle: Text(email ?? '-'),
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.event_outlined),
                            title: const Text('Joined'),
                            subtitle: Text(createdAt ?? '-'),
                          ),
                          const Divider(height: 0),
                          ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: const Text('Address'),
                            subtitle: Text(
                              userAddress ??
                                  (isLoadingLocation
                                      ? 'Loading...'
                                      : 'Location not set yet'),
                            ),
                            trailing: !hasLocation
                                ? IconButton(
                                    icon: const Icon(Icons.my_location),
                                    onPressed: isLoadingLocation ? null : _updateLocation,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!hasLocation)
                    CustomButton(
                      onPressed: isLoadingLocation ? null : _updateLocation,
                      buttonText:
                          isLoadingLocation ? 'Getting location...' : 'Set My Location',
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    onPressed: () async {
                      await dbHelper.logout();
                      if (mounted) {
                        Get.offAllNamed('/login');
                      }
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
