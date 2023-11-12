import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class LocationDetailView extends StatefulWidget {
  final double latitude;
  final double longitude;
  const LocationDetailView({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  Widget build(context, LocationDetailController controller) {
    controller.view = this;

    return Scaffold(
      appBar: AppBar(
        title: const Text("LocationDetail"),
        actions: const [],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Builder(
              builder: (context) {
                List<Marker> allMarkers = [
                  Marker(
                    point: LatLng(
                      latitude,
                      longitude,
                    ),
                    builder: (context) => const Icon(
                      Icons.pin_drop,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ];
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(
                        latitude,
                        longitude,
                      ),
                      zoom: 16,
                      interactiveFlags:
                          InteractiveFlag.all - InteractiveFlag.rotate,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example',
                      ),
                      MarkerLayer(
                        markers: allMarkers,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<LocationDetailView> createState() => LocationDetailController();
}
