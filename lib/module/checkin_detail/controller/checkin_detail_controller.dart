import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class CheckinDetailController extends GetxController {
  final _attendanceService = Get.find<AttendanceService>();

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

  // Variabel state untuk tombol (tidak ada perubahan)
  var isCheckedIn = false.obs;
  var isCheckedOut = false.obs;
  var checkInTime = "".obs;
  var checkOutTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    loading.value = true;
    // Panggil kedua fungsi secara bersamaan untuk mempercepat loading
    await Future.wait([
      getLocation(),
      updateButtonState(),
    ]);
    loading.value = false;
  }

  Future<void> getLocation() async {
    try {
      // Kita gunakan fungsi yang sudah ada di AttendanceService
      address.value = await _attendanceService.getCurrentAddress();
    } catch (e) {
      address.value = "Gagal memuat alamat: ${e.toString()}";
    }
  }

  Future<void> updateButtonState() async {
    try {
      // Gunakan fungsi yang lebih efisien
      final todayAttendance = await _attendanceService.getTodayAttendance();

      final todayCheckInTime = todayAttendance['check_in_time'] ?? "N/A";
      final todayCheckOutTime = todayAttendance['check_out_time'] ?? "N/A";

      isCheckedIn.value = todayCheckInTime != "N/A";
      isCheckedOut.value = todayCheckOutTime != "N/A";
      checkInTime.value = todayCheckInTime;
      checkOutTime.value = todayCheckOutTime;
    } catch (e) {
      print("Error updating button state: $e");
      // Set ke nilai default jika gagal
      isCheckedIn.value = false;
      isCheckedOut.value = false;
      checkInTime.value = "N/A";
      checkOutTime.value = "N/A";
    }
  }

  Future<void> doCheckIn() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Gunakan alur absensi baru yang aman
      final Position validPosition =
        await _attendanceService.validateAndGetPosition();
      await _attendanceService.checkInWithGps(validPosition);

      // Jika sukses, tutup dialog dan refresh state
      Get.back();
      await updateButtonState();

      Get.snackbar("Berhasil", "Check-in telah berhasil dicatat.",
          backgroundColor: Colors.green, colorText: Colors.white);

      // Refresh data di dasbor jika ada
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshData();
      }
      // Refresh halaman riwayat
      if (Get.isRegistered<AttendanceHistoryListController>()) {
        Get.find<AttendanceHistoryListController>().getAttendanceList();
      }
    } catch (e) {
      // Tangkap error (Fake GPS, dll) dan tampilkan
      Get.back();
      Get.snackbar(
        "Gagal Check-in",
        e.toString().replaceAll("Exception: ", ""),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  Future<void> doCheckOut() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      await _attendanceService.checkOut();
      Get.back();
      await updateButtonState();

      Get.snackbar("Berhasil", "Check-out telah berhasil dicatat.",
          backgroundColor: Colors.green, colorText: Colors.white);

      if (Get.isRegistered<AttendanceHistoryListController>()) {
        Get.find<AttendanceHistoryListController>().getAttendanceList();
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Gagal", "Gagal melakukan check-out.",
          backgroundColor: Colors.red.shade600, colorText: Colors.white);
    }
  }
}
