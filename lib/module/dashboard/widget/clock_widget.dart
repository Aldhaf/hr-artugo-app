import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClockController extends GetxController {
  var currentTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Update waktu setiap detik
    Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }
}

// Widget untuk menampilkan jam
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClockController());

    // Obx akan otomatis me-refresh Text ini setiap detik
    return Obx(() => Text(
          controller.currentTime.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ));
  }
}
