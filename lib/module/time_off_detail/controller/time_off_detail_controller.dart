import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get;
import '../../../shared/util/odoo_api/odoo_api.dart'; // Impor OdooApi Anda

class TimeOffDetailController extends GetxController {
  var isLoading = true.obs;
  var timeOffData = Rxn<Map<String, dynamic>>();
  final String timeOffId = Get.arguments; // Ambil ID dari argumen navigasi

  @override
  void onInit() {
    super.onInit();
    fetchTimeOffDetail();
  }

  Future<void> fetchTimeOffDetail() async {
    try {
      isLoading(true);
      final result = await OdooApi.getTimeOffDetail(int.parse(timeOffId));
      if (result != null) {
        timeOffData.value = result;
      }
    } finally {
      isLoading(false);
    }
  }
}