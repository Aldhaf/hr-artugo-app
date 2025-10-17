import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../core/data_state.dart';
import '../model/my_schedule_model.dart';
import '../model/work_pattern_model.dart';
import '../model/schedule_request_model.dart';
import '../widget/request_schedule_bottom_sheet.dart';
import 'package:hr_artugo_app/service/my_schedule_service/my_schedule_service.dart';
import 'package:table_calendar/table_calendar.dart';

class MyScheduleController extends GetxController {
  final _myScheduleService = Get.find<MyScheduleService>();

  // State untuk mengelola daftar jadwal (loading, success, error)
  var rosterState = Rx<DataState<List<Roster>>>(const DataLoading());
  // Pisahkan list untuk jadwal yang disetujui dan riwayat
  var approvedSchedules = <Roster>[].obs;
  var historySchedules = <Roster>[].obs;

  var availablePatterns = <WorkPattern>[].obs;
  var selectedRequests = <ScheduleRequest>[].obs;
  var isLoadingPatterns = false.obs;
  var bookedDates = <DateTime>{}.obs;

  // --- STATE BARU UNTUK KALENDER INTERAKTIF ---
  var calendarFormat = CalendarFormat.month.obs;
  var focusedDay =
      DateTime.now().obs; // Tanggal yang sedang menjadi fokus kalender
  var selectedShifts = <DateTime, WorkPattern>{}.obs;

  // --- STATE UNTUK TAB AKTIF ---
  var selectedTabIndex = 0.obs; // 0 untuk Riwayat, 1 untuk Ajukan Jadwal
  var bookedDatesWithStatus = <DateTime, String>{}.obs;

  var calendarRebuildKey = 0.obs;

  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    fetchMyRoster(); // Panggil fungsi saat controller diinisialisasi
    _fetchAvailableShifts();
    fetchBookedDatesForMonth(DateTime.now());
  }

  /// Fungsi ini dipanggil setiap kali pengguna menekan sebuah tanggal di kalender.
  void onDaySelected(DateTime selectedDay, DateTime newFocusedDay) {
    focusedDay.value = newFocusedDay;

    // Gunakan Get.bottomSheet untuk UI yang lebih modern
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          // Wrap akan membuat tinggi BottomSheet sesuai kontennya
          children: [
            // Header BottomSheet
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Pilih Shift untuk\n${DateFormat('EEEE, d MMMM yyyy').format(selectedDay)}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Opsi "Hari Libur / Tidak Masuk"
            ListTile(
              leading: const Icon(Icons.highlight_off),
              title: const Text("-- Hapus Pilihan / Hari Libur --"),
              onTap: () {
                final newMap = Map<DateTime, WorkPattern>.from(selectedShifts);
                newMap.remove(selectedDay);
                selectedShifts.value = newMap;
                calendarRebuildKey.value++;
                Get.back(); // Tutup bottom sheet
              },
            ),

            // Daftar Pilihan Shift
            ...availablePatterns.map((pattern) {
              return ListTile(
                leading: Icon(
                  Icons.watch_later_outlined,
                  color: Theme.of(Get.context!).primaryColor,
                ),
                title: Text(pattern.name),
                subtitle: Text(
                    "${_formatHour(pattern.workFrom)} - ${_formatHour(pattern.workTo)}"),
                onTap: () {
                  final newMap =
                      Map<DateTime, WorkPattern>.from(selectedShifts);
                  newMap[selectedDay] = pattern;
                  selectedShifts.value = newMap;
                  calendarRebuildKey.value++;
                  Get.back(); // Tutup bottom sheet
                },
              );
            }).toList(),
            const SizedBox(height: 20), // Beri sedikit ruang di bawah
          ],
        ),
      ),
    );
  }

  // Pastikan helper method ini ada di dalam controller
  String _formatHour(double? hour) {
    if (hour == null) return '--:--';
    int h = hour.toInt();
    int m = ((hour - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  /// Helper untuk mendapatkan event marker di bawah tanggal
  List<WorkPattern> getEventsForDay(DateTime day) {
    final pattern = selectedShifts[day];
    return pattern != null ? [pattern] : [];
  }

  Future<void> fetchBookedDatesForMonth(DateTime month) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final formatter = DateFormat('yyyy-MM-dd');

      // Panggil service yang memanggil API
      final results = await _myScheduleService.getBookedDates(
        formatter.format(firstDay),
        formatter.format(lastDay),
      );

      // Proses respons baru dari API
      final newBookedDates = <DateTime, String>{};
      for (final item in results) {
        // Sekarang Dart tahu 'item' adalah elemen dari List,
        // dan kita bisa mengaksesnya seperti Map.
        final dateString = item['date'] as String;
        final status = item['state'] as String;

        final date = DateTime.parse(dateString);
        newBookedDates[date] = status;
      }
      bookedDatesWithStatus.value = newBookedDates;

      calendarRebuildKey.value++;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat jadwal yang sudah ada: $e");
    }
  }

  Future<void> cancelRequest(int rosterId) async {
    try {
      // Tampilkan dialog konfirmasi
      await Get.defaultDialog(
          title: "Konfirmasi",
          middleText:
              "Apakah Anda yakin ingin membatalkan pengajuan jadwal ini?",
          textConfirm: "Ya, Batalkan",
          textCancel: "Tidak",
          confirmTextColor: Colors.white,
          onConfirm: () async {
            Get.back(); // Tutup dialog
            Get.snackbar("Memproses...", "Sedang membatalkan pengajuan Anda.");

            await _myScheduleService.cancelShiftRequest(rosterId);
            Get.snackbar("Berhasil", "Pengajuan jadwal telah dibatalkan.");

            // Muat ulang data untuk memperbarui tampilan
            fetchMyRoster();
          });
    } catch (e) {
      Get.snackbar("Gagal", "Gagal membatalkan pengajuan: ${e.toString()}");
    }
  }

  Future<void> _fetchAvailableShifts() async {
    try {
      isLoadingPatterns.value = true;
      // Panggil fungsi API yang baru
      final results = await _myScheduleService.getAvailableShifts();
      availablePatterns.assignAll(
        results.map((data) => WorkPattern.fromJson(data)).toList(),
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat daftar shift: $e");
    } finally {
      isLoadingPatterns.value = false;
    }
  }

  Future<void> fetchMyRoster() async {
    rosterState.value = const DataLoading();
    try {
      final results = await _myScheduleService.getMyRoster();

      // Ubah data JSON dari API menjadi List<Roster>
      final allRosters = results.map((data) => Roster.fromJson(data)).toList();

      // Filter dan pisahkan data
      approvedSchedules.assignAll(allRosters
          .where((r) =>
              r.status == 'Approved' &&
              r.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .toList());
      // Urutkan jadwal terdekat di paling atas
      approvedSchedules.sort((a, b) => a.date.compareTo(b.date));

      historySchedules.assignAll(allRosters);
      // Urutkan riwayat terbaru di paling atas
      historySchedules.sort((a, b) => b.date.compareTo(a.date));

      rosterState.value = DataSuccess(allRosters);
    } catch (e) {
      rosterState.value = DataError(e.toString());
    }
  }

  void openScheduleRequestForm() {
    // Reset list setiap kali form dibuka
    selectedRequests.clear();

    Get.bottomSheet(
      const RequestScheduleBottomSheet(),
      isScrollControlled: true, // Penting agar bottom sheet bisa full screen
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  void addDateRangeToRequest(List<DateTime> dates) {
    selectedRequests.assignAll(
      dates.map((date) => ScheduleRequest(date: date)).toList(),
    );
  }

  void updateSelectedPattern(int index, WorkPattern pattern) {
    selectedRequests[index].selectedPattern = pattern;
    selectedRequests.refresh(); // Update UI
  }

  Future<void> submitScheduleRequest() async {
    // Validasi: pastikan ada setidaknya satu shift yang dipilih
    if (selectedShifts.isEmpty) {
      Get.snackbar("Gagal",
          "Harap pilih setidaknya satu tanggal dan shift untuk diajukan.");
      return;
    }

    // Ubah data dari Map<DateTime, WorkPattern> ke format payload API
    final payload = selectedShifts.entries.map((entry) {
      final date = entry.key;
      final pattern = entry.value;
      return {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'work_pattern_id': pattern.id,
      };
    }).toList();

    final String monthName = DateFormat('MMMM yyyy').format(focusedDay.value);

    try {
      Get.snackbar("Memproses", "Mengirim pengajuan jadwal Anda...",
          showProgressIndicator: true);
      await _myScheduleService.submitMonthlyRoster(payload, monthName);

      if (Get.isSnackbarOpen) Get.back();

      Get.snackbar("Berhasil", "Pengajuan jadwal bulanan berhasil dikirim.");
      selectedShifts.clear(); // Bersihkan pilihan setelah berhasil
      fetchMyRoster();

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshData();
      }
    } catch (e) {
      if (Get.isSnackbarOpen) Get.back();
      Get.snackbar("Error", "Gagal mengirim pengajuan: $e");
    }
  }
}
