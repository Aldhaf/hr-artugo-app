import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class TimeOffHistoryListController extends GetxController
    with WidgetsBindingObserver {
  var items = <Map>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Mendaftarkan controller ini sebagai pengamat
    WidgetsBinding.instance.addObserver(this);
    // Memanggil fungsi untuk mengambil data saat controller pertama kali dibuat
    getTimeOffHistories();
  }

  @override
  void onClose() {
    // Selalu hapus pengamat saat controller ditutup
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Fungsi ini akan dipanggil setiap kali state aplikasi berubah
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Jika aplikasi kembali aktif/dibuka (dari background atau halaman lain)
    if (state == AppLifecycleState.resumed) {
      
      // Panggil fungsi untuk mengambil data terbaru
      getTimeOffHistories();
    }
  }

  getTimeOffHistories() async {
    loading.value = true;
    var response = await TimeOffService().get();
    items.value = List<Map>.from(response);
    loading.value = false;
  }
}
