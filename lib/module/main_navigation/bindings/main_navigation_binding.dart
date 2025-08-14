// lib/module/main_navigation/bindings/main_navigation_binding.dart

import 'package:get/get.dart';
import 'package:hyper_ui/module/dashboard/controller/dashboard_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan DashboardController di sini.
    // lazyPut berarti controller baru akan dibuat saat pertama kali dibutuhkan.
    Get.lazyPut<DashboardController>(() => DashboardController());

    // Jika halaman lain di navigasi Anda punya controller,
    // daftarkan juga di sini. Contoh:
    // Get.lazyPut<TimeOffController>(() => TimeOffController());
  }
}