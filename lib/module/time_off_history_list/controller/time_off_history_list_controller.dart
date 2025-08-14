import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:hr_artugo_app/core.dart' hide Get;

class TimeOffHistoryListController extends GetxController
    with WidgetsBindingObserver {
  // Gunakan List<Map> yang reaktif dan loading flag
  var items = <Map>[].obs;
  var loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Daftarkan controller ini sebagai pengamat
    WidgetsBinding.instance.addObserver(this);
    // Panggil fungsi untuk mengambil data saat controller pertama kali dibuat
    getTimeOffHistories();
  }

  @override
  void onClose() {
    // Selalu hapus pengamat saat controller ditutup
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // --- LOGIKA UTAMA ADA DI SINI ---
  // Fungsi ini akan dipanggil setiap kali state aplikasi berubah
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Jika aplikasi kembali aktif/dibuka (dari background atau halaman lain)
    if (state == AppLifecycleState.resumed) {
      print("Aplikasi kembali aktif, memuat ulang riwayat Time Off...");
      // Panggil fungsi untuk mengambil data terbaru
      getTimeOffHistories();
    }
  }

  // Nama fungsi tetap sama, tetapi isinya diubah untuk GetX
  getTimeOffHistories() async {
    loading.value = true;
    var response = await TimeOffService().get();
    items.value = List<Map>.from(response); // Update nilai .value
    loading.value = false; // Update nilai .value
  }
}
