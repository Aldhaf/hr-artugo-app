import 'package:hyper_ui/module/checkin_detail/widget/check_out_button.dart';
import 'package:hyper_ui/module/checkin_detail/widget/time_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

import '../widget/check_in_button.dart';

class CheckinDetailView extends StatefulWidget {
  const CheckinDetailView({Key? key}) : super(key: key);

  Widget build(context, CheckinDetailController controller) {
    controller.view = this;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Check In",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        actions: const [],
      ),
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Builder(
                            builder: (context) {
                              List<Marker> allMarkers = [
                                Marker(
                                  point: LatLng(
                                    controller.position.latitude,
                                    controller.position.longitude,
                                  ),
                                  builder: (context) => Icon(
                                    Icons.pin_drop,
                                    color: Colors.red,
                                    size: Get.width * 0.1,
                                  ),
                                ),
                              ];
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: FlutterMap(
                                  options: MapOptions(
                                    center: LatLng(
                                      controller.position.latitude,
                                      controller.position.longitude,
                                    ),
                                    zoom: 16,
                                    interactiveFlags: InteractiveFlag.all -
                                        InteractiveFlag.rotate,
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
                      ),
                    ],
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
                            Column(
                              children: [
                                const TimeWidget(),
                                const SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  controller.address,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12.0,
                                ),
                                Row(
                                  children: const [
                                    CheckInButton(),
                                    SizedBox(
                                      width: 12.0,
                                    ),
                                    CheckOutButton(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  State<CheckinDetailView> createState() => CheckinDetailController();
}
