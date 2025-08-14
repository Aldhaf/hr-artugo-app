// lib/module/notification/bindings/notification_binding.dart

import 'package:get/get.dart';
import '../controller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan NotificationController agar siap digunakan oleh NotificationView
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}