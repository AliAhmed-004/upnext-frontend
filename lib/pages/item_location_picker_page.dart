import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../env.dart';

class ItemLocationPickerPage extends StatefulWidget {
  const ItemLocationPickerPage({super.key});

  @override
  State<ItemLocationPickerPage> createState() => _ItemLocationPickerPageState();
}

class _ItemLocationPickerPageState extends State<ItemLocationPickerPage> {
  LatLng? _selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Item Location')),
      body: FlutterMap(
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
      floatingActionButton: _selectedPoint == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: () {
                Get.back(result: _selectedPoint);
              },
            ),
    );
  }
}
