import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class CheckInButton extends StatelessWidget {
  const CheckInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckinDetailController>();

    return Obx(() {
      if (controller.isCheckedIn.value == true) {
        return Expanded(
          child: QButton(label: controller.checkInTime.value, onPressed: () {}),
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
