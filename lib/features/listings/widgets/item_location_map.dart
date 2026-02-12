import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:upnext/core/constants/env.dart';

/// Widget displaying a non-interactive map with a location marker.
/// 
/// Used to show the location of a listing item.
class ItemLocationMap extends StatelessWidget {
  final LatLng location;
  
  const ItemLocationMap({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    debugPrint("Rendering map for location: $location");

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: location,
          // Disable user interactions - this is just a display map
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${Env.mapApiKey}',
            userAgentPackageName: 'com.spudbyte.upnext',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location,
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
    );
  }
}
