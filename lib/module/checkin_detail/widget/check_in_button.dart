// lib/module/checkin_detail/widget/check_in_button.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get;

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller yang sudah ada
    final controller = Get.find<CheckinDetailController>();

    return Obx(() {
      if (controller.isCheckedIn.value == null) {
        return Expanded(
          child: QButton(label: "Loading...", onPressed: () {}), // <-- Gunakan fungsi kosong
        );
      }
      if (controller.isCheckedIn.value == true) {
        // Tambahkan onPressed
        return Expanded(
          child: QButton(
            label: controller.checkInTime.value, onPressed: () {}), // <-- Gunakan fungsi kosong
          );
      }
      return Expanded(
        child: QButton(
          label: "Check In",
          onPressed: () => controller.doCheckIn(),
          color: Colors.green,
        ),
      );
    });
  }
}