import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class AttendanceHistoryListController extends GetxController {
  final _attendanceService = Get.find<AttendanceService>();

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
    var history = await _attendanceService.getHistory();
    items.value = List<Map>.from(history);
    loading.value = false;
  }
}
