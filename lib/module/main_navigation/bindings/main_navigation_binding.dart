import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

// --- Import Service ---
import 'package:hr_artugo_app/service/firebase_service/firebase_service.dart';
import 'package:hr_artugo_app/service/leave_type_service/leave_type_service.dart';
import 'package:hr_artugo_app/service/my_schedule_service/my_schedule_service.dart';
import 'package:hr_artugo_app/module/my_schedule/controller/my_schedule_controller.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());

    // GRUP 1 (Dasar setelah login)
    Get.lazyPut<OdooApiService>(() => OdooApiService(), fenix: true);
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);

    // GRUP 2 membutuhkan Grup 1
    Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    Get.lazyPut<LeaveTypeService>(() => LeaveTypeService(), fenix: true);
    Get.lazyPut<TimeOffService>(() => TimeOffService(), fenix: true);
    Get.lazyPut<MyScheduleService>(() => MyScheduleService(), fenix: true);

    // GRUP 3 membutuhkan Grup 2
    Get.lazyPut<AttendanceService>(() => AttendanceService(), fenix: true);

    // GRUP 4 membutuhkan Controller Halaman Utama)
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<AttendanceHistoryListController>(
        () => AttendanceHistoryListController());
    Get.lazyPut<TimeOffHistoryListController>(
        () => TimeOffHistoryListController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<MyScheduleController>(() => MyScheduleController());
  }
}
