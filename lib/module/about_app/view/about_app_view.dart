import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/about_app_controller.dart';

class AboutAppView extends StatelessWidget {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutAppController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("About App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan logo Anda
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.apps, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "ARTTEND",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              "Versi ${controller.appVersion.value}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            )),
            const SizedBox(height: 20),
            const Text(
              "Aplikasi absensi dan manajemen HR untuk karyawan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Text(
              "© 2025 PT Kreasi Arduo Indonesia. All Rights Reserved.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}