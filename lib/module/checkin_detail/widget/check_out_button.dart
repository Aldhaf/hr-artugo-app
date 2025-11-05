import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class CheckOutButton extends StatelessWidget {
  const CheckOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckinDetailController>();

    return Obx(() {
      // Tombol Check Out dinonaktifkan jika belum check-in atau sudah check-out
      bool enabled = controller.isCheckedIn.value == true &&
          controller.isCheckedOut.value == false;

      // Menampilkan waktu jika sudah check-out
      if (controller.isCheckedOut.value == true) {
        return Expanded(
          child: QButton(
              label: controller.checkOutTime.value,
              onPressed: () {}),
        );
      }

      return Expanded(
        child: QButton(
          label: "Check Out",
          color: enabled ? Colors.red : Colors.grey,
          onPressed: enabled ? () => controller.doCheckOut() : () {},
        ),
      );
    });
  }
}
