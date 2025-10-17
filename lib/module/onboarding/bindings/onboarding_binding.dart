import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../controller/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // Gunakan lazyPut agar Controller hanya dibuat saat benar-benar dibutuhkan
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}