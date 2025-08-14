import 'package:get/get.dart';
import '../controller/about_app_controller.dart';

class AboutAppBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan NotificationController agar siap digunakan oleh NotificationView
    Get.lazyPut<AboutAppController>(() => AboutAppController());
  }
}
