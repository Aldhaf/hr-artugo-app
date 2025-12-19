import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:hr_artugo_app/service/time_off_service/time_off_service.dart';

class TimeOffDetailController extends GetxController {
  var isLoading = true.obs;
  var timeOffData = Rxn<Map<String, dynamic>>();
  final String timeOffId = Get.arguments;
  final _timeOffService = Get.find<TimeOffService>();

  @override
  void onInit() {
    super.onInit();
    fetchTimeOffDetail();
  }

  Future<void> fetchTimeOffDetail() async {
    try {
      isLoading(true);
      final result =
          await _timeOffService.getTimeOffDetail(int.parse(timeOffId));
      if (result != null) {
        timeOffData.value = result;
      }
    } finally {
      isLoading(false);
    }
  }
}
