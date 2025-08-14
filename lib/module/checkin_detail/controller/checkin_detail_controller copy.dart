import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart'
    hide Get; // Pastikan import ini ada untuk AttendanceService

class CheckinDetailController extends GetxController {
  // Variabel state yang sudah ada
  var loading = true.obs;
  var address = "".obs;
  var position = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0.0,
    heading: 0,
    headingAccuracy: 0.0,
    speed: 0,
    speedAccuracy: 0,
  ).obs;

  // Variabel state untuk tombol
  var isCheckedIn = Rxn<bool>();
  var isCheckedOut = Rxn<bool>();
  var checkInTime = "".obs;
  var checkOutTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  loadInitialData() async {
    loading.value = true;
    await getLocation();
    await updateButtonState(); // Panggil method baru untuk update status tombol
    loading.value = false;
  }

  getLocation() async {
    // ... (Logika getLocation Anda yang sudah ada, tidak perlu diubah)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    // ... sisa logika permission ...
    position.value = await Geolocator.getCurrentPosition();
    await getAddress();
  }

  getAddress() async {
    try {
      // Logika permintaan Dio yang sudah ada
      var response = await Dio().get(
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.value.latitude}&lon=${position.value.longitude}",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
          },
        ),
      );
      Map obj = response.data;
      address.value = obj["display_name"];
    } on DioException catch (e) {
      // <-- Tangkap DioException secara spesifik
      // PRINT SEMUA DETAIL ERROR INI KE KONSOL
      print("--- Dio Error Details ---");
      print("Error Message: ${e.message}");
      print("Status Code: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
      print("Request Path: ${e.requestOptions.path}");
      print("Request Headers: ${e.requestOptions.headers}");
      print("-------------------------");

      // Beri nilai default agar aplikasi tidak crash
      address.value = "Gagal mendapatkan alamat.";
    }
  }

  // --- METHOD BARU UNTUK LOGIKA TOMBOL ---

  // Method ini akan mengambil status absensi terakhir dan memperbarui UI
  updateButtonState() async {
    var histories = await AttendanceService.getHistory();

    isCheckedIn.value = await AttendanceService.isCheckedInToday();
    isCheckedOut.value = await AttendanceService.isCheckedOutToday();

    if (histories.isNotEmpty) {
      final lastHistory = histories.first;
      if (lastHistory["check_in"] != null && lastHistory["check_in"] != false) {
        DateTime utcDate = DateTime.parse(lastHistory["check_in"] + "Z");
        checkInTime.value = DateFormat("kk:mm:ss").format(utcDate.toLocal());
      }
      if (lastHistory["check_out"] != null &&
          lastHistory["check_out"] != false) {
        DateTime utcDate = DateTime.parse(lastHistory["check_out"] + "Z");
        checkOutTime.value = DateFormat("kk:mm:ss").format(utcDate.toLocal());
      }
    }
  }

  // Method yang akan dipanggil oleh tombol Check In
  doCheckIn() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    await AttendanceService.checkin();
    await updateButtonState(); // Refresh status tombol setelah check-in
    Get.back(); // Tutup dialog loading

    // --- TAMBAHKAN KODE DI BAWAH INI ---
    // Cek apakah DashboardController sudah ada, lalu panggil refresh.
    if (Get.isRegistered<DashboardController>()) {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.refreshData();
    }
    // ------------------------------------

    // Refresh halaman riwayat jika perlu
    // Di dalam doCheckIn() dan doCheckOut()
    if (Get.isRegistered<AttendanceHistoryListController>()) {
      // Gunakan Get.find() untuk mendapatkan instance controller yang sudah ada
      final historyController = Get.find<AttendanceHistoryListController>();
      historyController.getAttendanceList();
    }
  }

  // Method yang akan dipanggil oleh tombol Check Out
  doCheckOut() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    await AttendanceService.checkOut();
    await updateButtonState(); // Refresh status tombol setelah check-out
    Get.back();

    if (Get.isRegistered<AttendanceHistoryListController>()) {
      // PERBAIKAN DI SINI
      final historyController = Get.find<AttendanceHistoryListController>();
      historyController.getAttendanceList();
    }
  }
}
