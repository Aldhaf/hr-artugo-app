import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:hr_artugo_app/core.dart';

// 1. Ubah menjadi StatelessWidget yang lebih ringan
class LocationDetailView extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationDetailView({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. Tidak perlu controller lagi
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Detail"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 16,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all - InteractiveFlag.rotate,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                child: const Icon(
                  Icons.location_on,
                  size: 40.0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
