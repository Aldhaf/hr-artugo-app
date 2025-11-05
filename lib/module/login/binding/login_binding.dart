import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
  }
}
