import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppController extends GetxController {
  var appVersion = "1.0.0".obs;

  @override
  void onInit() {
    super.onInit();
    _getAppVersion();
  }

  void _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }
}