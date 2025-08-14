import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// 1. Ubah menjadi StatelessWidget
class CheckinDetailView extends StatelessWidget {
  const CheckinDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. Daftarkan dan ambil instance controller dengan Get.put()
    final controller = Get.put(CheckinDetailController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Check In"),
      ),
      // 3. Bungkus bagian body dengan Obx agar bisa "mendengarkan" perubahan
      body: Obx(() {
        // 4. Akses variabel reaktif dengan .value
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Stack(
            children: [
              // Menggunakan CheckinMapView yang sudah kita buat sebelumnya
              CheckinMapView(
                // 4. Akses variabel reaktif dengan .value
                position: controller.position.value,
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const TimeWidget(),
                        const SizedBox(height: 12.0),
                        // 4. Akses variabel reaktif dengan .value
                        Text(
                          controller.address.value,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          children: const [
                            CheckInButton(),
                            SizedBox(width: 12.0),
                            CheckOutButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// Ini adalah widget peta yang sudah kita pisahkan sebelumnya
// Pastikan ia menerima 'Position' bukan 'CheckinDetailController'
class CheckinMapView extends StatelessWidget {
  final Position position;

  const CheckinMapView({
    Key? key,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Marker> allMarkers = [
      Marker(
        point: LatLng(
          position.latitude,
          position.longitude,
        ),
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40.0,
        ),
      ),
    ];

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          position.latitude,
          position.longitude,
        ),
        initialZoom: 16,
        interactionOptions: InteractionOptions( // <-- TAMBAHKAN PEMBUNGKUS INI
          flags: InteractiveFlag.all - InteractiveFlag.rotate, // <-- PINDAHKAN KE DALAM 'flags'
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        MarkerLayer(
          markers: allMarkers,
        ),
      ],
    );
  }
}
