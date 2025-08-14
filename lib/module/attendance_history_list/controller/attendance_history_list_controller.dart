// lib/module/attendance_history_list/controller/attendance_history_list_controller.dart

import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart';

class AttendanceHistoryListController extends GetxController {
  // Gunakan List<Map> yang reaktif untuk menampung data absensi
  var items = <Map>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getAttendanceList();
  }

  getAttendanceList() async {
    loading.value = true;
    var history = await AttendanceService.getHistory();
    items.value = List<Map>.from(history);
    loading.value = false;
  }
}
