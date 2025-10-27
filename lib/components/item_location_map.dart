import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ItemLocationMap extends StatelessWidget {
  final LatLng location;
  const ItemLocationMap({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    debugPrint("Rendering map for location: $location");

    return Container(
      height: 200,
      color: Colors.grey[300],
      child: FlutterMap(
        options: MapOptions(
          initialCenter: location,
          // Disable user interactions
          interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate:
                // TODO: Add the api key to env file
                'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=Ww4nWHUs4BLQV20sy7zB',

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
