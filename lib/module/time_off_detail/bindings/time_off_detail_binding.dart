import 'package:get/get.dart';
import '../controller/time_off_detail_controller.dart';

class TimeOffDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimeOffDetailController>(() => TimeOffDetailController());
  }
}