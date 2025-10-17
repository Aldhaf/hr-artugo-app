// lib/module/main_navigation/bindings/main_navigation_binding.dart

import 'package:get/get.dart';
import 'package:hr_artugo_app/module/dashboard/controller/dashboard_controller.dart';
import 'package:hr_artugo_app/module/attendance_history_list/controller/attendance_history_list_controller.dart';
import 'package:hr_artugo_app/module/my_schedule/controller/my_schedule_controller.dart'; // <-- IMPORT BARU

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan DashboardController di sini.
    // lazyPut berarti controller baru akan dibuat saat pertama kali dibutuhkan.
    Get.lazyPut<DashboardController>(() => DashboardController());

    // Ini memastikan controller-nya selalu ada di memori saat di navigasi utama
    Get.put(AttendanceHistoryListController(), permanent: true);
    Get.lazyPut<MyScheduleController>(
      () => MyScheduleController(),
    );

    // Jika halaman lain di navigasi Anda punya controller,
    // daftarkan juga di sini. Contoh:
    // Get.lazyPut<TimeOffController>(() => TimeOffController());
  }
}
