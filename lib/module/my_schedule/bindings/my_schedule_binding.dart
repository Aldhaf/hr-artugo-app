import 'package:get/get.dart';
import '../controller/my_schedule_controller.dart';

class MyScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyScheduleController>(
      () => MyScheduleController(),
    );
  }
}