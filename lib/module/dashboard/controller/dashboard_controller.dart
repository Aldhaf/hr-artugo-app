import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core/data_state.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/cache_service/cache_service.dart';
import '../../../service/work_profile_service/work_profile_service.dart';
import '../../../model/work_profile_model.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

// Tambahkan 'with WidgetsBindingObserver'
class DashboardController extends GetxController with WidgetsBindingObserver {
  final _cacheService = CacheService();

  // --- Variabel State ---
  var userName = "".obs;
  var locationState = Rx<DataState<String>>(const DataLoading());
  var checkInTime = "N/A".obs;
  var checkOutTime = "N/A".obs;
  var workingHours = "00:00:00".obs;
  var presentDays = 0.obs;
  var absentDays = 0.obs;
  var lateInDays = 0.obs;
  var isLoading = true.obs;
  var hasCheckedInToday = false.obs;
  var workPatternInfo = "".obs;
  var storeLocationInfo = "".obs;
  var jobTitle = "".obs;
  var dailyHours = <DailyWorkHour>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Daftarkan observer
    WidgetsBinding.instance.addObserver(this);
    // Panggil refresh data pertama kali
    loadData();
    refreshLocation();
    fetchWorkingHoursChart();
  }

  @override
  void onClose() {
    // Hapus observer saat controller ditutup
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> fetchWorkingHoursChart() async {
    try {
      // Tentukan rentang tanggal, misalnya 7 hari terakhir
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));
      final formatter = DateFormat('yyyy-MM-dd');
      final String startDateStr = formatter.format(startDate);
      final String endDateStr = formatter.format(endDate);

      // Panggil API untuk mendapatkan data live
      final List<dynamic> results =
          await OdooApi.getDailyWorkedHours(startDateStr, endDateStr);

      print("[DEBUG-CHART] Flutter menerima RAW DATA dari Odoo: $results");

      // Ubah data JSON dari API menjadi List<DailyWorkHour>
      final List<DailyWorkHour> liveData = results.map((item) {
        return DailyWorkHour(
          date: DateTime.parse(item['date']),
          hours: (item['hours'] as num).toDouble(),
        );
      }).toList();

      print(
          "[DEBUG-CHART] Data setelah di-parsing di Flutter: ${liveData.map((d) => '${d.date}: ${d.hours} jam').toList()}");

      dailyHours.assignAll(liveData);
    } catch (e) {
      print("Gagal memuat data chart: $e");
      dailyHours.clear(); // Kosongkan data jika error
    }
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

  // --- FUNGSI BARU UNTUK REFRESH RINGAN ---
  Future<void> _updateMonthlySummary() async {
    try {
      // Panggil getMonthSummary dari instance tersebut
      final summary = await AttendanceService.getMonthSummary();

      presentDays.value = summary['present'] ?? 0;
      absentDays.value = summary['absent'] ?? 0;
      lateInDays.value = summary['late'] ?? 0;
    } catch (e) {
      print("Gagal memperbarui ringkasan bulanan: $e");
    }
  }

  // --- Fungsi Utama untuk Memuat Semua Data ---
  Future<void> refreshData() async {
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
    userName.value = data['userName'] as String? ?? "User";
    checkInTime.value = data['check_in_time'] as String? ?? "N/A";
    checkOutTime.value = data['check_out_time'] as String? ?? "N/A";
    workingHours.value = data['worked_hours'] as String? ?? "00:00:00";
    hasCheckedInToday.value = checkInTime.value != "N/A";
    presentDays.value = data['present'] as int? ?? 0;
    absentDays.value = data['absent'] as int? ?? 0;
    lateInDays.value = data['late'] as int? ?? 0;

    final workProfileService = Get.find<WorkProfileService>();
    final WorkProfile? profile = workProfileService.workProfile;

    print(
        "[DEBUG-DASHBOARD] Mengambil profil dari service. Jabatan: ${profile?.jobTitle}");

    /*
    print("======================================");
    print("DATA DI DALAM DASHBOARD CONTROLLER:");
    print(
        "Nama Toko dari Service: ${workProfileService.workProfile?.storeLocation?.name}");
    print(
        "Pola Kerja dari Service: ${workProfileService.workProfile?.workPattern?.name}");
    print("======================================");
    */

    if (profile != null) {
      jobTitle.value = profile.jobTitle ?? ""; // Ambil jobTitle dari service
    }

    final WorkPattern? pattern = profile?.workPattern;
    final StoreLocation? location = profile?.storeLocation;

    // Format teks untuk ditampilkan di UI
    if (pattern != null) {
      // Ubah jam dari float (misal 8.5) menjadi format jam (08:30)
      int startHour = pattern.workFrom.toInt();
      int startMinute = ((pattern.workFrom - startHour) * 60).round();
      int endHour = pattern.workTo.toInt();
      int endMinute = ((pattern.workTo - endHour) * 60).round();

      String startTime =
          "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
      String endTime =
          "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";

      workPatternInfo.value = "Jam Kerja: $startTime - $endTime";
    }

    if (location != null && location.name.isNotEmpty) {
      storeLocationInfo.value = "Lokasi: ${location.name}";
    }
  }

  // --- doCheckIn() VERSI OPTIMAL ---
  void doCheckIn() async {
    // 1. UI Optimistis: Langsung perbarui state UI
    final currentTime = DateTime.now();
    checkInTime.value = DateFormat("HH:mm:ss").format(currentTime);
    hasCheckedInToday.value = true;

    try {
      // 2. Kirim permintaan ke server di latar belakang
      await AttendanceService.checkin();

      // Catat peristiwa 'check_in' ke Firebase Analytics
      FirebaseAnalytics.instance.logEvent(
        name: 'attendance_check_in',
        parameters: {
          'employee_name': userName.value,
          'check_in_time': checkInTime.value,
        },
      );

      // 3. Setelah sukses, panggil refresh ringan untuk data bulanan
      await _updateMonthlySummary();

      Get.snackbar(
        "Berhasil",
        "Check-in telah berhasil dicatat.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh halaman riwayat jika sedang dibuka
      if (Get.isRegistered<AttendanceHistoryListController>()) {
        Get.find<AttendanceHistoryListController>().getAttendanceList();
      }
    } catch (e) {
      // 4. Rollback: Jika gagal, kembalikan UI ke state semula
      checkInTime.value = "N/A";
      hasCheckedInToday.value = false;
      Get.snackbar(
        "Gagal",
        "Gagal melakukan check-in. Periksa koneksi Anda.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // --- doCheckOut() VERSI OPTIMAL ---
  void doCheckOut() async {
    // 1. UI Optimistis: Simpan state lama dan perbarui UI
    final oldCheckOutTime = checkOutTime.value;
    final currentTime = DateTime.now();
    checkOutTime.value = DateFormat("HH:mm:ss").format(currentTime);

    try {
      // 2. Kirim permintaan ke server
      await AttendanceService.checkOut();

      // 3. Panggil refresh ringan (opsional, karena checkout tidak mengubah summary)
      // await _updateMonthlySummary(); // Bisa di-uncomment jika ada logika yang berubah
      FirebaseAnalytics.instance.logEvent(
        name: 'attendance_check_out',
        parameters: {
          'employee_name': userName.value,
          'check_out_time': checkOutTime.value,
        },
      );

      Get.snackbar(
        "Berhasil",
        "Check-out telah berhasil dicatat.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      if (Get.isRegistered<AttendanceHistoryListController>()) {
        Get.find<AttendanceHistoryListController>().getAttendanceList();
      }
    } catch (e) {
      // 4. Rollback: Kembalikan UI jika gagal
      checkOutTime.value = oldCheckOutTime;
      Get.snackbar(
        "Gagal",
        "Gagal melakukan check-out.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
