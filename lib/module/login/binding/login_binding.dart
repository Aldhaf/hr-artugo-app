import 'package:get/get.dart';
import '../controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Gunakan lazyPut agar controller hanya dibuat saat pertama kali dibutuhkan
    Get.lazyPut<LoginController>(() => LoginController());
  }
}