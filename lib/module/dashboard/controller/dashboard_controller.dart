import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/cache_service/cache_service.dart';
import 'package:hr_artugo_app/core/data_state.dart';
import 'package:hr_artugo_app/module/attendance_history_list/controller/attendance_history_list_controller.dart';

// Tambahkan 'with WidgetsBindingObserver'
class DashboardController extends GetxController with WidgetsBindingObserver {
  final _cacheService = CacheService();

  // --- Variabel State (tidak berubah) ---
  var userName = "".obs;
  var locationState = Rx<DataState<String>>(const DataLoading());

  var checkInTime = "N/A".obs;
  var checkOutTime = "N/A".obs;
  var workingHours = "00:00:00".obs;

  var presentDays = 0.obs;
  var absentDays = 0.obs;
  var lateInDays = 0.obs;

  var isLoading = true.obs;

  // --- PERUBAHAN 1: Tambahkan state boolean untuk status check-in ---
  var hasCheckedInToday = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Daftarkan observer
    WidgetsBinding.instance.addObserver(this);
    // Panggil refresh data pertama kali
    loadData();
    refreshLocation();
  }

  @override
  void onClose() {
    // Hapus observer saat controller ditutup
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Fungsi ini akan dipanggil setiap kali state aplikasi berubah
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Jika aplikasi kembali aktif (dari background atau halaman lain)
    if (state == AppLifecycleState.resumed) {
      print("App resumed, refreshing dashboard...");
      // Panggil refresh data
      refreshData();
    }
  }

  // --- ALUR LOADING BARU ---
  void loadData() async {
    // 1. Coba muat dari cache terlebih dahulu
    final cachedData = await _cacheService.getDashboardCache();
    if (cachedData != null) {
      // Jika ada cache, langsung tampilkan dan matikan loading
      _updateStateFromMap(cachedData);
      isLoading.value = false;
    }

    // 2. Selalu panggil refreshData untuk mengambil data terbaru dari network
    // Jika tidak ada cache, UI akan menampilkan loading sampai ini selesai.
    // Jika ada cache, ini berjalan di latar belakang.
    await refreshData();
  }

  // --- Fungsi Utama untuk Memuat Semua Data ---
  Future<void> refreshData() async {
    // Hanya tampilkan loading jika tidak ada cache sama sekali
    if (await _cacheService.getDashboardCache() == null) {
      isLoading.value = true;
    }

    try {
      // 1. FOKUS HANYA PADA PENGAMBILAN DATA
      final results = await Future.wait([
        AttendanceService.getTodayAttendance(),
        AttendanceService.getMonthSummary(),
        AttendanceService.getCurrentAddress(),
      ]);

      // 2. OLAH DATA MENJADI SATU MAP YANG RAPI
      final preparedData = {
        "userName": OdooApi.session?.userName,
        "location": results[2],
        "check_in_time": (results[0] as Map<String, String>)['check_in_time'],
        "check_out_time": (results[0] as Map<String, String>)['check_out_time'],
        "worked_hours": (results[0] as Map<String, String>)['worked_hours'],
        "present": (results[1] as Map<String, int>)['present'],
        "absent": (results[1] as Map<String, int>)['absent'],
        "late": (results[1] as Map<String, int>)['late'],
      };

      // 3. PANGGIL HELPER METHOD & SIMPAN KE CACHE
      _updateStateFromMap(preparedData);
      await _cacheService.saveDashboardCache(preparedData);
    } catch (e) {
      print("Error refreshing dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // TAMBAHKAN FUNGSI BARU INI
  Future<void> refreshLocation() async {
    locationState.value = const DataLoading();
    try {
      final newLocation = await AttendanceService.getCurrentAddress();

      // Cek apakah hasilnya adalah pesan error dari service kita
      if (newLocation.contains("Gagal") ||
          newLocation.contains("ditolak") ||
          newLocation.contains("mati")) {
        locationState.value = DataError(newLocation);
      } else {
        locationState.value = DataSuccess(newLocation);
      }
    } catch (e) {
      locationState.value = DataError("Error: ${e.toString()}");
    }
  }

  // Buat helper method untuk mencegah duplikasi kode
  void _updateStateFromMap(Map<String, dynamic> data) {
    // Helper method ini menjadi "satu-satunya sumber kebenaran"
    // untuk memperbarui semua state dashboard.

    userName.value = data['userName'] as String? ?? "User";

    checkInTime.value = data['check_in_time'] as String? ?? "N/A";
    checkOutTime.value = data['check_out_time'] as String? ?? "N/A";
    workingHours.value = data['worked_hours'] as String? ?? "00:00:00";
    hasCheckedInToday.value = checkInTime.value != "N/A";

    presentDays.value = data['present'] as int? ?? 0;
    absentDays.value = data['absent'] as int? ?? 0;
    lateInDays.value = data['late'] as int? ?? 0;
  }

  doCheckIn() async {
    // Tampilkan dialog loading yang tidak bisa ditutup oleh user
    Get.dialog(
      const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Panggil satu fungsi utama yang aman dari service
      await AttendanceService.checkin();

      // Jika berhasil, tutup dialog dan refresh data dari server
      Get.back(); // Tutup dialog loading
      await refreshData(); // Sinkronkan UI dengan data terbaru

      Get.snackbar(
        "Berhasil",
        "Check-in telah berhasil dicatat.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Cek apakah halaman history sedang aktif, jika iya, refresh datanya.
      if (Get.isRegistered<AttendanceHistoryListController>()) {
        final historyController = Get.find<AttendanceHistoryListController>();
        historyController.getAttendanceList();
      }
    } catch (e) {
      // Jika ada error apapun dari service, tangkap di sini
      Get.back(); // Tutup dialog loading
      Get.snackbar(
        "Gagal",
        e
            .toString()
            .replaceAll("Exception: ", ""), // Tampilkan pesan error yang bersih
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  doCheckOut() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      await AttendanceService.checkOut();
    } catch (e) {
      Get.snackbar("Error", "Gagal melakukan check-out.");
    } finally {
      await refreshData();
      Get.back();

      // Cek apakah halaman history sedang aktif, jika iya, refresh datanya.
      if (Get.isRegistered<AttendanceHistoryListController>()) {
        final historyController = Get.find<AttendanceHistoryListController>();
        historyController.getAttendanceList();
      }
    }
  }
}
