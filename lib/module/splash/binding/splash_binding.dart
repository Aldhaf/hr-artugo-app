// lib/module/splash/binding/splash_binding.dart
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan controller jika splash screen Anda membutuhkannya di masa depan
    // Get.lazyPut<SplashController>(() => SplashController());
  }
}