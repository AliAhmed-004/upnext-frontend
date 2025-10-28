import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../env.dart';

class ItemLocationPickerPage extends StatefulWidget {
  const ItemLocationPickerPage({super.key});

  @override
  State<ItemLocationPickerPage> createState() => _ItemLocationPickerPageState();
}

class _ItemLocationPickerPageState extends State<ItemLocationPickerPage> {
  LatLng? _selectedPoint;
  final MapController _mapController = MapController();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Disabled',
        'Please turn on the device\'s GPS.',
        backgroundColor: Colors.red[200],
      );
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required.',
          backgroundColor: Colors.red[200],
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied',
        'Please enable location in settings.',
        backgroundColor: Colors.red[200],
      );
      return;
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedPoint = currentLocation;
    });

    _mapController.move(currentLocation, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Item Location')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(33.6844, 73.0479),
          initialZoom: 13,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedPoint = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${Env.mapApiKey}',
            userAgentPackageName: 'com.spudbyte.upnext',
          ),
          if (_selectedPoint != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedPoint!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'current_location',
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),

          const SizedBox(height: 12),
          if (_selectedPoint != null)
            FloatingActionButton(
              heroTag: 'confirm_location',
              onPressed: () {
                Get.back(result: _selectedPoint);
              },
              child: const Icon(Icons.check),
            ),
        ],
      ),
    );
  }
}
