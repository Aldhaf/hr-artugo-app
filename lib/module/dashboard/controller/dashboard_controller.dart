import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core/data_state.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:hr_artugo_app/model/work_profile_model.dart';
import '../../../service/work_profile_service/work_profile_service.dart';
import '../../../service/cache_service/cache_service.dart';
import '../../../service/connectivity_service/connectivity_service.dart';
import '../model/daily_work_hour_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

// import '../view/dashboard_view.dart';

enum AttendancePeriod { thisMonth, lastMonth }

enum DashboardStatus { loading, success, offline, error }

class DashboardController extends GetxController with WidgetsBindingObserver {
  // --- Service ---
  final _workProfileService = Get.find<WorkProfileService>();
  final _attendanceService = Get.find<AttendanceService>();
  final _cacheService = Get.find<CacheService>();
  final _connectivityService = Get.find<ConnectivityService>();

  // --- State Utama ---
  var status = DashboardStatus.loading.obs;
  var errorMessage = Rxn<String>();
  var isShowingCachedData = false.obs;

  // Variabel State untuk UI
  var isLoading = true.obs;
  var isChartLoading = false.obs;
  var userName = "".obs;
  var jobTitle = "".obs;
  var checkInTime = "N/A".obs;
  var checkOutTime = "N/A".obs;
  var hasCheckedInToday = false.obs;
  var workPatternInfo = "Belum ada jadwal".obs;
  var hasApprovedScheduleToday = false.obs;
  var locationState = Rx<DataState<String>>(const DataLoading());

  var isCurrentlyCheckedIn = false.obs;
  var showThankYouMessage = false.obs;

  // Variabel untuk Ringkasan Bulanan
  var presentDays = 0.obs;
  var lateInDays = 0.obs;
  var absentDays = 0.obs;

  // Variabel untuk Grafik Jam Kerja
  var dailyHours = <DailyWorkHour>[].obs;
  var totalHoursSummary = "00:00 hrs".obs;
  var overtimeSummary = "00:00 hrs".obs;
  var chartStartDate = DateTime.now().subtract(const Duration(days: 6)).obs;
  var chartEndDate = DateTime.now().obs;
  var chartDateRangeText = "".obs;
  var selectedPeriod = AttendancePeriod.thisMonth.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ever(_connectivityService.isOnline, _handleConnectivityChange);
    _loadInitialData();
    refreshData();
    _updateDateRangeText();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Fungsi yang dipanggil saat status koneksi berubah
  void _handleConnectivityChange(bool isOnline) {
    if (isOnline &&
        (status.value == DashboardStatus.offline ||
            status.value == DashboardStatus.error)) {
      // Jika kembali online dan sebelumnya error/offline, coba muat ulang
      refreshData();
    } else if (!isOnline) {
      // Jika menjadi offline
      status.value = DashboardStatus.offline;
      errorMessage.value = "Anda sedang offline.";
      isShowingCachedData.value = true; // Mencoba menampilkan cache
      // Tidak perlu load cache di sini, loadInitialData/refreshData sudah menanganinya
    }
  }

  // Fungsi baru untuk memuat data awal (memeriksa cache dulu)
  Future<void> _loadInitialData() async {
    status.value = DashboardStatus.loading;
    errorMessage.value = null;
    isShowingCachedData.value = false;

    // Coba muat dari cache dulu
    final cachedData = await _cacheService.getDashboardCache();
    if (cachedData != null) {
      try {
        _updateStateFromData(cachedData);
        status.value =
            DashboardStatus.success; // Anggap sukses dulu (dari cache)
        isShowingCachedData.value = true;
      } catch (e) {
        await _cacheService.clearAllCache();
      }
    }

    // Jika online, selalu coba refresh di latar belakang setelah cache (jika ada) tampil
    if (_connectivityService.isOnline.value) {
      // Panggil refreshData TAPI jangan await, biarkan jalan di background
      refreshData();
    } else if (cachedData == null) {
      // Offline DAN tidak ada cache
      status.value = DashboardStatus.offline;
      errorMessage.value = "Anda sedang offline dan tidak ada data tersimpan.";
    } else {
      // Offline TAPI ada cache (sudah ditampilkan)
      status.value = DashboardStatus.offline;
      errorMessage.value = "Anda sedang offline. Menampilkan data terakhir.";
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
    }
  }

  // fungsi untuk mengubah periode dan memuat ulang data
  Future<void> changeAttendancePeriod(AttendancePeriod newPeriod) async {
    if (selectedPeriod.value == newPeriod) return;

    selectedPeriod.value = newPeriod;

    try {
      // Panggil fungsi refresh yang me-return Map
      final summary = await _refreshMonthlySummary();

      presentDays.value = summary['present'] ?? 0;
      absentDays.value = summary['absent'] ?? 0;
      lateInDays.value = summary['late'] ?? 0;

      // status.value = DashboardStatus.success;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat ringkasan bulan lalu.");
    }
  }

  // Menerima hasil dari pemilih tanggal dan memuat ulang grafik
  void applyDateRange(DateTimeRange? picked) {
    if (picked != null) {
      chartStartDate.value = picked.start;
      chartEndDate.value = picked.end ?? picked.start;
      _updateDateRangeText();

      isChartLoading.value = true; // <-- Mulai loading
      errorMessage.value = null; // Hapus error lama (jika ada)

      fetchWorkingHoursChart().then((chartData) {
        _updateChartState(chartData);
        isChartLoading.value = false; // <-- Selesai loading
      }).catchError((e) {
        Get.snackbar("Error", "Gagal memuat data jam kerja.");
        dailyHours.clear(); // Kosongkan data chart jika error
        isChartLoading.value = false; // <-- Selesai loading (meskipun error)
      });
    }
    Get.back();
  }

  // Memperbarui teks rentang tanggal di UI.
  void _updateDateRangeText() {
    final start = DateFormat('d MMM').format(chartStartDate.value);
    final end = DateFormat('d MMM').format(chartEndDate.value);
    chartDateRangeText.value = "$start - $end";
  }

  // Fungsi utama yang memuat semua data yang dibutuhkan dasbor.
  Future<void> refreshData() async {
    // Hanya jalankan jika online
    if (!_connectivityService.isOnline.value) {
      Get.snackbar("Offline", "Tidak ada koneksi internet.");
      status.value = DashboardStatus.offline;
      errorMessage.value = "Tidak ada koneksi internet.";
      isShowingCachedData.value = true;
      return;
    }

    // Hanya set loading jika BUKAN refresh saat cache sudah ada
    // Ini agar shimmer tidak muncul lagi saat refresh manual
    if (!isShowingCachedData.value) {
      status.value = DashboardStatus.loading;
    }
    errorMessage.value = null;
    isShowingCachedData.value = false; // Data baru bukan dari cache

    // Mulai panggil refreshLocation() secara terpisah (jangan ditunggu/await)
    // Biarkan state-nya sendiri yang diupdate (loading -> success/error)
    refreshLocation(); // <-- Panggil refreshLocation di sini

    try {
      // Gunakan Map untuk menampung semua hasil API
      final Map<String, dynamic> freshData = {};
      // Menjalankan semua API call secara paralel
      await Future.wait([
        _workProfileService.fetchProfile().then((profile) {
          freshData['profile'] = profile?.toJson(); // Simpan profile sbg Map
          userName.value = profile?.employeeName ?? "User";
          jobTitle.value = profile?.jobTitle ?? "";
          _updateWorkPatternInfo(profile); // Fungsi helper
        }),
        _attendanceService.getTodayAttendance().then((todayAttendance) {
          freshData['todayAttendance'] = todayAttendance; // Simpan sbg Map
          _updateAttendanceState(todayAttendance);
          checkInTime.value = todayAttendance['check_in_time'] ?? "N/A";
          checkOutTime.value = todayAttendance['check_out_time'] ?? "N/A";
          hasCheckedInToday.value = checkInTime.value != "N/A";
        }),
        _refreshMonthlySummary().then((summary) {
          freshData['monthlySummary'] = summary; // Simpan summary sbg Map
          presentDays.value = summary['present'] ?? 0;
          absentDays.value = summary['absent'] ?? 0;
          lateInDays.value = summary['late'] ?? 0;
        }),
        fetchWorkingHoursChart().then((chartData) {
          freshData['workingHours'] = chartData; // Simpan data chart sbg Map
          _updateChartState(chartData); // Fungsi helper
        }),
      ]);

      // --- SIMPAN DATA BARU KE CACHE ---
      await _cacheService.saveDashboardCache(freshData);

      status.value = DashboardStatus.success; // Semua berhasil
    } catch (e) {
      status.value = DashboardStatus.error;
      isShowingCachedData.value = true; // Coba tampilkan cache jika ada error

      // --- PESAN ERROR ---
      if (e is DioException) {
        if (e.error is SocketException) {
          errorMessage.value =
              "Tidak bisa terhubung ke server. Periksa koneksi Anda.";
          status.value =
              DashboardStatus.offline; // Anggap offline jika socket error
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage.value = "Koneksi ke server timeout.";
        } else {
          errorMessage.value =
              "Terjadi masalah pada server: ${e.response?.statusCode ?? ''}";
        }
      } else if (e is SocketException) {
        errorMessage.value =
            "Tidak bisa terhubung ke server. Periksa koneksi Anda.";
        status.value = DashboardStatus.offline;
      } else {
        errorMessage.value = "Terjadi kesalahan: ${e.toString()}";
      }

      // Jika error, coba muat dari cache sebagai fallback
      final cachedData = await _cacheService.getDashboardCache();
      if (cachedData != null) {
        try {
          _updateStateFromData(cachedData);
        } catch (parseError) {
          await _cacheService.clearAllCache(); // Hapus cache jika rusak
          errorMessage.value =
              "Gagal memuat data baru maupun data cache."; // Update error message
        }
      } else {
        // Reset state jika tidak ada cache sama sekali
        _resetStateToDefault();
      }
    } finally {
      // Pindahkan save cache dan set status success ke sini agar dieksekusi setelah try/catch
      if (status.value != DashboardStatus.error &&
          status.value != DashboardStatus.offline) {
        // Jika tidak error/offline, simpan data (jika freshData ada) dan set sukses
        // Anda mungkin perlu membuat freshData dapat diakses di sini atau merestruktur sedikit
        // await _cacheService.saveDashboardCache(freshData); // Contoh
        status.value = DashboardStatus.success;
        isShowingCachedData.value = false; // Karena data baru saja dimuat
      }
    }
  }

  void _updateAttendanceState(Map<String, dynamic> attendanceData) {
    checkInTime.value = attendanceData['check_in_time'] ?? "N/A";
    checkOutTime.value = attendanceData['check_out_time'] ?? "N/A";

    bool hasCheckedIn = checkInTime.value != "N/A";
    bool hasCheckedOut = checkOutTime.value != "N/A";

    isCurrentlyCheckedIn.value = hasCheckedIn && !hasCheckedOut;
    showThankYouMessage.value = hasCheckedIn && hasCheckedOut;
  }

  // Mengupdate state dari data Map (baik dari cache maupun API)
  void _updateStateFromData(Map<String, dynamic> data) {
    // Update profile
    if (data['profile'] != null) {
      final profileData = data['profile'] as Map<String, dynamic>;
      userName.value = profileData['employee_name'] ?? "User";
      jobTitle.value = profileData['job_title'] ?? "";
      // Buat WorkProfile dummy untuk update work pattern (atau parse lengkap jika perlu)
      final profile = WorkProfile.fromJson(profileData);
      _updateWorkPatternInfo(profile);
    }
    // Update today attendance
    if (data['todayAttendance'] != null) {
      final todayAtt = data['todayAttendance'] as Map<String, dynamic>;
      _updateAttendanceState(todayAtt);
      checkInTime.value = todayAtt['check_in_time'] ?? "N/A";
      checkOutTime.value = todayAtt['check_out_time'] ?? "N/A";
      hasCheckedInToday.value = checkInTime.value != "N/A";
    }
    // Update monthly summary
    if (data['monthlySummary'] != null) {
      final summary = data['monthlySummary'] as Map<String, dynamic>;
      presentDays.value = (summary['present'] as num?)?.toInt() ?? 0;
      absentDays.value = (summary['absent'] as num?)?.toInt() ?? 0;
      lateInDays.value = (summary['late'] as num?)?.toInt() ?? 0;
    }
    // Update working hours chart
    if (data['workingHours'] != null) {
      final chartData = data['workingHours'] as Map<String, dynamic>;
      _updateChartState(chartData);
    }
    // Location tidak di-cache, jadi tidak perlu di-update dari sini
  }

  Future<void> refreshLocation() async {
    locationState.value = const DataLoading(); // Set loading untuk lokasi
    try {
      // Jangan cek koneksi di sini, biarkan service yang menangani timeout/error
      final newLocation = await _attendanceService.getCurrentAddress();

      // Cek apakah hasilnya adalah pesan error dari service kita
      if (newLocation.contains("Gagal") ||
          newLocation.contains("ditolak") ||
          newLocation.contains("mati")) {
        locationState.value = DataError(newLocation);
      } else {
        locationState.value = DataSuccess(newLocation);
      }
    } catch (e) {
      // Tangani error spesifik jika perlu (misal timeout)
      locationState.value = DataError("Gagal memuat lokasi.");
    }
  }

  // Mengupdate fungsi _refreshMonthlySummary agar me-return Map
  Future<Map<String, int>> _refreshMonthlySummary() async {
    try {
      final now = DateTime.now();
      final targetMonth = selectedPeriod.value == AttendancePeriod.thisMonth
          ? now
          : DateTime(now.year, now.month - 1, 1);
      final summary = await _attendanceService.getMonthSummary(targetMonth);
      return summary;
    } catch (e) {
      return {"present": 0, "absent": 0, "late": 0};
    }
  }

  // Mengupdate fungsi fetchWorkingHoursChart agar me-return Map
  Future<Map<String, dynamic>> fetchWorkingHoursChart() async {
    try {
      final formatter = DateFormat('yyyy-MM-dd');
      final String startDateStr = formatter.format(chartStartDate.value);
      final String endDateStr = formatter.format(chartEndDate.value);
      final Map<String, dynamic> apiResponse = await _attendanceService
          .getWorkingHoursChartData(startDateStr, endDateStr);
      return apiResponse;
    } catch (e) {
      return {'total_hours': 0.0, 'overtime': 0.0, 'details': []};
    }
  }

  // Mengupdate info pola kerja dari data profile
  void _updateWorkPatternInfo(WorkProfile? profile) {
    if (profile != null &&
        profile.workPattern != null &&
        profile.workPattern!.name.isNotEmpty) {
      final pattern = profile.workPattern!;
      hasApprovedScheduleToday.value = true;
      int startHour = pattern.workFrom.toInt();
      int startMinute = ((pattern.workFrom - startHour) * 60).round();
      int endHour = pattern.workTo.toInt();
      int endMinute = ((pattern.workTo - endHour) * 60).round();
      String startTime =
          "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
      String endTime =
          "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";
      workPatternInfo.value = "$startTime - $endTime";
    } else {
      hasApprovedScheduleToday.value = false;
      workPatternInfo.value = "Belum ada jadwal";
    }
  }

  // Mengupdate state terkait chart dari data API/cache
  void _updateChartState(Map<String, dynamic> chartData) {
    double total = (chartData['total_hours'] as num? ?? 0.0).toDouble();
    double overtime = (chartData['overtime'] as num? ?? 0.0).toDouble();
    int totalInt = total.toInt();
    int overtimeInt = overtime.toInt();
    totalHoursSummary.value =
        "${totalInt}:${((total - totalInt) * 60).round().toString().padLeft(2, '0')} hrs";
    overtimeSummary.value =
        "${overtimeInt}:${((overtime - overtimeInt) * 60).round().toString().padLeft(2, '0')} hrs";

    final List<dynamic> results = chartData['details'] as List<dynamic>? ?? [];
    dailyHours.assignAll(results.map((item) {
      WorkDayStatus status;
      switch (item['status']) {
        case 'absent':
          status = WorkDayStatus.absent;
          break;
        case 'holiday':
          status = WorkDayStatus.holiday;
          break;
        default:
          status = WorkDayStatus.worked;
      }
      // Memastikan parsing tanggal aman
      DateTime date;
      try {
        date = DateTime.parse(item['date']);
      } catch (e) {
        date = DateTime.now();
      }
      return DailyWorkHour(
        date: date,
        hours: (item['hours'] as num? ?? 0.0).toDouble(),
        status: status,
      );
    }).toList());
  }

  // Mengembalikan state ke nilai default jika fetch gagal dan tidak ada cache
  void _resetStateToDefault() {
    userName.value = "User";
    jobTitle.value = "";
    checkInTime.value = "N/A";
    checkOutTime.value = "N/A";
    hasCheckedInToday.value = false;
    workPatternInfo.value = "Belum ada jadwal";
    hasApprovedScheduleToday.value = false;
    locationState.value = const DataLoading();
    presentDays.value = 0;
    lateInDays.value = 0;
    absentDays.value = 0;
    dailyHours.clear();
    totalHoursSummary.value = "00:00 hrs";
    overtimeSummary.value = "00:00 hrs";
  }

  // Fungsi untuk melakukan Check In.
  void doCheckIn() async {
    Get.snackbar(
        "Memproses Absensi", "Mohon tunggu, memvalidasi lokasi Anda...",
        showProgressIndicator: true,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 25) // Beri durasi lebih lama
        );

    try {
      final Position position =
          await _attendanceService.validateAndGetPosition();

      // Kirim data Check-in ke server
      await _attendanceService.checkInWithGps(position);

      // Tutup snackbar loading SEGERA
      if (Get.isSnackbarOpen) Get.back();

      // UPDATE STATE UI LANGSUNG (Optimistic UI Update)
      isCurrentlyCheckedIn.value = true;
      showThankYouMessage.value = false; // Pastikan pesan "Terima Kasih" hilang

      // Tampilkan Snackbar Sukses
      Get.snackbar("Berhasil", "Check-in telah berhasil dicatat.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition
              .BOTTOM); // Pindahkan ke bawah agar tidak menghalangi

      refreshData().then((_) {
        // Refresh riwayat setelah data utama selesai di-refresh
        if (Get.isRegistered<AttendanceHistoryListController>()) {
          Get.find<AttendanceHistoryListController>().getAttendanceList();
        }
      }).catchError((e) {
        // Anda bisa menampilkan snackbar error di sini jika perlu
      });
    } catch (e) {
      // Tutup snackbar loading jika error
      if (Get.isSnackbarOpen) Get.back();

      // TIDAK perlu rollback state UI di sini karena kita update setelah API berhasil
      Get.snackbar("Gagal Check-in", e.toString().replaceAll("Exception: ", ""),
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM, // Pindahkan ke bawah
          duration: const Duration(seconds: 5));
    }
  }

  void doCheckOut() async {
    // Simpan state lama dan perbarui UI
    // final oldCheckOutTime = checkOutTime.value;
    // final currentTime = DateTime.now();
    // checkOutTime.value = DateFormat("HH:mm:ss").format(currentTime);
    Get.snackbar("Memproses...", "Sedang mencatat check-out Anda...",
        showProgressIndicator: true,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 10));

    try {
      await _attendanceService.checkOut(); // Panggil API checkout
      if (Get.isSnackbarOpen) Get.back(); // Tutup snackbar loading
      isCurrentlyCheckedIn.value = false;
      showThankYouMessage.value = true;
      // Tampilkan Snackbar Sukses
      Get.snackbar(
        "Berhasil",
        "Check-out telah berhasil dicatat.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      await refreshData(); // Tetap await agar history refresh konsisten

      // Refresh riwayat jika perlu
      if (Get.isRegistered<AttendanceHistoryListController>()) {
        Get.find<AttendanceHistoryListController>().getAttendanceList();
      }
      // Logika Analytics (tidak berubah)
      FirebaseAnalytics.instance.logEvent(
        name: 'attendance_check_out',
        parameters: {
          'employee_name': userName.value,
          'check_out_time': checkOutTime.value,
        },
      );
    } catch (e) {
      if (Get.isSnackbarOpen) Get.back(); // Tutup snackbar loading jika error

      // Rollback tidak perlu jika UI optimis dihapus
      // checkOutTime.value = oldCheckOutTime;

      Get.snackbar(
        "Gagal",
        "Gagal melakukan check-out: ${e.toString().replaceAll('Exception: ', '')}",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
