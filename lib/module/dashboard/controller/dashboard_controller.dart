import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core/data_state.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/work_profile_service/work_profile_service.dart';
import '../../../service/attendance_service/attendance_service.dart';
import '../model/daily_work_hour_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

enum AttendancePeriod { thisMonth, lastMonth }

class DashboardController extends GetxController with WidgetsBindingObserver {
  final _workProfileService = Get.find<WorkProfileService>();
  final _attendanceService = Get.find<AttendanceService>();

  // --- Variabel State untuk UI ---
  var isLoading = true.obs;
  var userName = "".obs;
  var jobTitle = "".obs;
  var checkInTime = "N/A".obs;
  var checkOutTime = "N/A".obs;
  var hasCheckedInToday = false.obs;
  var workPatternInfo = "Belum ada jadwal".obs;
  var hasApprovedScheduleToday = false.obs;
  var locationState = Rx<DataState<String>>(const DataLoading());

  // --- Variabel untuk Ringkasan Bulanan ---
  var presentDays = 0.obs;
  var lateInDays = 0.obs;
  var absentDays = 0.obs;

  // --- Variabel untuk Grafik Jam Kerja ---
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
    refreshData(); // Panggil refresh data utama saat inisialisasi
    _updateDateRangeText();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData(); // Selalu segarkan data saat aplikasi kembali aktif
    }
  }

  // fungsi baru untuk mengubah periode dan memuat ulang data
  Future<void> changeAttendancePeriod(AttendancePeriod newPeriod) async {
    if (selectedPeriod.value == newPeriod)
      return; // Jangan lakukan apa-apa jika pilihannya sama

    selectedPeriod.value = newPeriod;
    await _refreshMonthlySummary(); // Panggil fungsi refresh yang terpisah
  }

  // fungsi terpisah untuk refresh ringkasan bulanan
  Future<void> _refreshMonthlySummary() async {
    try {
      final now = DateTime.now();
      // Tentukan bulan target berdasarkan pilihan
      final targetMonth = selectedPeriod.value == AttendancePeriod.thisMonth
          ? now
          : DateTime(now.year, now.month - 1, 1); // Bulan lalu

      final summary = await _attendanceService.getMonthSummary(targetMonth);

      // Update state UI
      presentDays.value = summary['present'] ?? 0;
      absentDays.value = summary['absent'] ?? 0;
      lateInDays.value = summary['late'] ?? 0;
    } catch (e) {
      print("Error refreshing monthly summary: $e");
      // Reset ke nol jika gagal
      presentDays.value = 0;
      absentDays.value = 0;
      lateInDays.value = 0;
    }
  }

  // Menampilkan dialog pemilih rentang tanggal untuk grafik.
  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          DateTimeRange(start: chartStartDate.value, end: chartEndDate.value),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      chartStartDate.value = picked.start;
      chartEndDate.value = picked.end;
      _updateDateRangeText();
      fetchWorkingHoursChart(); // Ambil data baru untuk grafik
    }
  }

  /// Memperbarui teks rentang tanggal di UI.
  void _updateDateRangeText() {
    final start = DateFormat('d MMM').format(chartStartDate.value);
    final end = DateFormat('d MMM').format(chartEndDate.value);
    chartDateRangeText.value = "$start - $end";
  }

  /// Mengambil dan mem-parsing data untuk grafik jam kerja.
  Future<void> fetchWorkingHoursChart() async {
    try {
      final formatter = DateFormat('yyyy-MM-dd');
      final String startDateStr = formatter.format(chartStartDate.value);
      final String endDateStr = formatter.format(chartEndDate.value);

      final Map<String, dynamic> apiResponse = await _attendanceService
          .getWorkingHoursChartData(startDateStr, endDateStr);

      double total = (apiResponse['total_hours'] as num? ?? 0.0).toDouble();
      double overtime = (apiResponse['overtime'] as num? ?? 0.0).toDouble();

      int totalInt = total.toInt();
      int overtimeInt = overtime.toInt();
      totalHoursSummary.value =
          "${totalInt}:${((total - totalInt) * 60).round().toString().padLeft(2, '0')} hrs";
      overtimeSummary.value =
          "${overtimeInt}:${((overtime - overtimeInt) * 60).round().toString().padLeft(2, '0')} hrs";

      final List<dynamic> results =
          apiResponse['details'] as List<dynamic>? ?? [];
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
        return DailyWorkHour(
          date: DateTime.parse(item['date']),
          hours: (item['hours'] as num).toDouble(),
          status: status,
        );
      }).toList());
    } catch (e) {
      print("Gagal memuat data chart dari Odoo: $e");
      dailyHours.clear();
      totalHoursSummary.value = "00:00 hrs";
      overtimeSummary.value = "00:00 hrs";
    }
  }

  // Fungsi utama yang memuat semua data yang dibutuhkan dasbor.
  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _workProfileService.fetchProfile().then((profile) {
          userName.value = profile?.employeeName ?? "User";
          jobTitle.value = profile?.jobTitle ?? "";

          // --- Logika Penampilan Jam Shift ---
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
        }),

        _attendanceService.getTodayAttendance().then((todayAttendance) {
          // Langsung proses hasilnya di sini
          checkInTime.value = todayAttendance['check_in_time'] ?? "N/A";
          checkOutTime.value = todayAttendance['check_out_time'] ?? "N/A";
          hasCheckedInToday.value = checkInTime.value != "N/A";
        }),

        _attendanceService.getCurrentAddress().then((currentAddress) {
          // Langsung proses hasilnya di sini
          locationState.value = DataSuccess(currentAddress);
        }),

        // Fungsi-fungsi ini (Future<void>) tetap dipanggil, tapi hasilnya diabaikan
        _refreshMonthlySummary(),
        fetchWorkingHoursChart(),
      ]);
    } catch (e) {
      print("Error refreshing dashboard: $e");
      Get.snackbar("Error", "Gagal memuat data dasbor: ${e.toString()}");
      // Set state error jika perlu
      locationState.value = const DataError("Gagal memuat data");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLocation() async {
    locationState.value = const DataLoading();
    try {
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
      locationState.value = DataError("Error: ${e.toString()}");
    }
  }

  /// Fungsi untuk melakukan Check In yang aman.
  void doCheckIn() async {
    Get.snackbar(
        "Memproses Absensi", "Mohon tunggu, memvalidasi lokasi Anda...",
        showProgressIndicator: true, duration: const Duration(seconds: 25));

    try {
      final Position position =
          await _attendanceService.validateAndGetPosition();
      await _attendanceService.checkInWithGps(position);

      if (Get.isSnackbarOpen) Get.back();

      // Panggil refreshData() untuk memuat ulang SEMUA data setelah check-in
      await refreshData();

      Get.snackbar("Berhasil", "Check-in telah berhasil dicatat.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      if (Get.isSnackbarOpen) Get.back();
      Get.snackbar("Gagal Check-in", e.toString().replaceAll("Exception: ", ""),
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 5));
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
      await _attendanceService.checkOut();

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
