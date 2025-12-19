import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../core/data_state.dart';
import '../model/my_schedule_model.dart';
import '../model/work_pattern_model.dart';
import '../model/schedule_request_model.dart';
import '../widget/request_schedule_bottom_sheet.dart';
import '../../../shared/widget/custom_confirmation_dialog.dart';
import 'package:hr_artugo_app/service/my_schedule_service/my_schedule_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widget/rejected_schedule_detail_sheet.dart';
import 'package:collection/collection.dart';

class MyScheduleController extends GetxController {
  final _myScheduleService = Get.find<MyScheduleService>();

  // State Daftar Jadwal
  var rosterState = Rx<DataState<List<Roster>>>(const DataLoading());
  var approvedSchedules = <Roster>[].obs;
  var historySchedules = <Roster>[].obs;

  // State Jadwal Terdekat
  var upcomingFilterDays = 3.obs;

  // State Riwayat Pengajuan
  var historySearchQuery = ''.obs;
  var historyMonthFilter = Rxn<DateTime>();
  var historyStatusFilter = 'All'.obs;

  // State untuk mengisi dropdown bulan
  var availableHistoryMonths = <DateTime>[].obs;

  // State Grouping
  // var groupedHistorySchedules = <String, List<Roster>>{}.obs;

  // State Expansion
  // var expandedMonths = <String, bool>{}.obs;

  // State Pola Kerja & Bottom Sheet Lama
  var availablePatterns = <WorkPattern>[].obs;
  var isLoadingPatterns = false.obs;
  var selectedRequests = <ScheduleRequest>[].obs;
  var bookedDates = <DateTime>{}.obs;

  // Hapus state kalender interaktif jika tidak dipakai di versi ini
  var calendarFormat = CalendarFormat.month.obs;
  var focusedDay = DateTime.now().obs;
  var selectedShifts = <DateTime, WorkPattern>{}.obs;
  var bookedDatesWithStatus = <DateTime, String>{}.obs;
  var calendarRebuildKey = 0.obs;

  // State Tab
  var selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Panggil fetch awal
    fetchMyRoster();
    _fetchAvailableShifts();
    fetchBookedDatesForMonth(
        DateTime.now()); // Panggil ini untuk bottom sheet lama
  }

  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  // Menampilkan bottom sheet yang berisi detail jadwal yang ditolak, termasuk alasan penolakan.
  void showRejectionDetail(Roster schedule) {
    // Pastikan hanya jadwal yang ditolak yang bisa dilihat detailnya
    if (schedule.status != 'Rejected') {
      return;
    }

    // Panggil Get.bottomSheet dengan widget kustom
    Get.bottomSheet(
      RejectedScheduleDetailSheet(
          schedule: schedule), // Widget dari file terpisah
      // backgroundColor: Theme.of(Get.context!).cardColor, // Warna diatur di sheet
      // isScrollControlled: true, // Aktifkan jika kontennya bisa sangat panjang
    );
  }

  void onDaySelected(DateTime selectedDay, DateTime newFocusedDay) {
    // Normalisasi tanggal yang dipilih ke tengah malam untuk pencocokan Map key
    DateTime normalizedSelectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final currentStatus = bookedDatesWithStatus.value[normalizedSelectedDay];

    // Jangan izinkan pemilihan jika tanggal sudah di-approve
    if (currentStatus == 'Approved') {
      Get.snackbar("Info", "Tanggal ini sudah memiliki jadwal yang disetujui.");
      return;
    }

    focusedDay.value = newFocusedDay; // Update fokus kalender

    // Tampilkan Bottom Sheet untuk memilih shift
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          children: [
            // Header BottomSheet
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Select Shifts for\n${DateFormat('EEEE, d MMMM yyyy').format(selectedDay)}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Opsi Hapus Pilihan
            ListTile(
              leading: const Icon(Icons.highlight_off, color: Colors.red),
              title: const Text("-- Clear Choice / Holiday --"),
              onTap: () {
                // Buat salinan Map, hapus entri untuk tanggal ini, update state
                final newMap = Map<DateTime, WorkPattern>.from(selectedShifts);
                newMap.remove(
                    normalizedSelectedDay); // Gunakan tanggal yang sudah dinormalisasi
                selectedShifts.value = newMap;
                calendarRebuildKey
                    .value++; // Trigger rebuild kalender untuk hapus marker
                Get.back(); // Tutup bottom sheet
              },
            ),
            // Obx di sini agar daftar shift otomatis update jika availablePatterns berubah
            Obx(() => Column(
                  mainAxisSize: MainAxisSize
                      .min, // Agar Column tidak memakan ruang berlebih
                  children: availablePatterns.map((pattern) {
                    return ListTile(
                      leading: Icon(
                        Icons.watch_later_outlined,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                      title: Text(pattern.name),
                      subtitle: Text(
                          "${_formatHour(pattern.workFrom)} - ${_formatHour(pattern.workTo)}"),
                      onTap: () {
                        // Buat salinan Map, tambahkan/update entri, update state
                        final newMap =
                            Map<DateTime, WorkPattern>.from(selectedShifts);
                        newMap[normalizedSelectedDay] =
                            pattern; // Gunakan tanggal yang sudah dinormalisasi
                        selectedShifts.value = newMap;
                        calendarRebuildKey
                            .value++; // Trigger rebuild kalender untuk tambah/update marker
                        Get.back(); // Tutup bottom sheet
                      },
                    );
                  }).toList(),
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
      backgroundColor: Colors.transparent, // Latar diatur di Container
      // isScrollControlled: true, // Mungkin perlu jika daftar shift sangat panjang
    );
  }

  // Fungsi formatHour mungkin masih dipakai di view
  String _formatHour(double? hour) {
    if (hour == null) return '--:--';
    int h = hour.toInt();
    int m = ((hour - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  // Getter untuk "Jadwal Terdekat" yang difilter
  List<Roster> get filteredApprovedSchedules {
    final now = DateTime.now();
    // Menentukan tanggal akhir berdasarkan filter
    final endDate = now.add(Duration(days: upcomingFilterDays.value));

    return approvedSchedules.where((schedule) {
      // Ambil jadwal dari "hari ini" sampai "X hari ke depan"
      final scheduleDate =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      final today = DateTime(now.year, now.month, now.day);

      return (scheduleDate.isAtSameMomentAs(today) ||
              scheduleDate.isAfter(today)) &&
          scheduleDate.isBefore(endDate);
    }).toList();
  }

  // Getter untuk "Riwayat Pengajuan" yang difilter
  List<Roster> get filteredHistorySchedules {
    // Daftar lengkap
    List<Roster> filteredList = List.from(historySchedules);

    // Filter berdasarkan Bulan (jika dipilih)
    if (historyMonthFilter.value != null) {
      final selectedMonth = historyMonthFilter.value!;
      filteredList = filteredList.where((roster) {
        return roster.date.year == selectedMonth.year &&
            roster.date.month == selectedMonth.month;
      }).toList();
    }

    // Filter berdasarkan Status (jika bukan "All")
    if (historyStatusFilter.value != 'All') {
      filteredList = filteredList.where((roster) {
        return roster.status.toLowerCase() ==
            historyStatusFilter.value.toLowerCase();
      }).toList();
    }

    // Filter berdasarkan Search Query (jika diisi)
    if (historySearchQuery.value.isNotEmpty) {
      String query = historySearchQuery.value.toLowerCase();
      filteredList = filteredList.where((roster) {
        return roster.workPatternName.toLowerCase().contains(query) ||
            DateFormat('d MMM yyyy')
                .format(roster.date)
                .toLowerCase()
                .contains(query) ||
            roster.status.toLowerCase().contains(query);
      }).toList();
    }

    return filteredList;
  }

  // Helper untuk TableCalendar, menyediakan list event (WorkPattern)
  // yang akan ditampilkan sebagai marker di bawah tanggal.
  List<WorkPattern> getEventsForDay(DateTime day) {
    // Normalisasi 'day' ke tengah malam untuk pencocokan Map key
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    // Mencari pattern yang dipilih untuk tanggal ini di map selectedShifts
    final pattern = selectedShifts[normalizedDay];
    // Kembalikan list berisi pattern jika ditemukan, atau list kosong jika tidak
    return pattern != null ? [pattern] : [];
  }

  // Mengambil data tanggal yang sudah terisi (requested/approved) dari Odoo
  // untuk bulan yang sedang ditampilkan di kalender.
  Future<void> fetchBookedDatesForMonth(DateTime month) async {
    try {
      // Menentukan hari pertama dan terakhir bulan yang diminta
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final formatter = DateFormat('yyyy-MM-dd');

      // Memanggil service untuk mengambil data dari API Odoo
      final results = await _myScheduleService.getBookedDates(
        formatter.format(firstDay),
        formatter.format(lastDay),
      );

      // Proses hasil API menjadi Map<DateTime, String>
      final newBookedDates = <DateTime, String>{};
      for (final item in results) {
        final dateString = item['date'] as String?;
        final status = item['state'] as String?;
        if (dateString == null || status == null)
          continue; // Lewati data tidak valid

        try {
          final date = DateTime.parse(dateString);
          // Normalisasi tanggal ke tengah malam sebagai key Map
          final normalizedDate = DateTime(date.year, date.month, date.day);
          newBookedDates[normalizedDate] = status; // Simpan statusnya
        } catch (e) {}
      }

      if (!mapEquals(bookedDatesWithStatus.value, newBookedDates)) {
        bookedDatesWithStatus.value = newBookedDates;
        calendarRebuildKey.value++;
      }
    } catch (e) {
      // Menampilkan error jika gagal mengambil data
      Get.snackbar("Error", "Gagal memuat jadwal ter-booking: $e");
    }
  }

  // Mengirimkan jadwal shift yang telah dipilih pengguna ke server Odoo.
  Future<void> submitScheduleRequest() async {
    // Validasi
    if (selectedShifts.isEmpty) {
      Get.snackbar("Gagal", "Harap pilih setidaknya satu tanggal dan shift.");
      return;
    }

    // Urut tanggal yang dipilih (Start & End)
    final sortedDates = selectedShifts.keys.toList()..sort();
    final DateTime startDate = sortedDates.first;
    final DateTime endDate = sortedDates.last;

    // Membuat Nama Batch yang Dinamis
    // Jika dalam bulan yang sama: "November 2025"
    // Jika lintas bulan: "27 Nov - 04 Dec 2025"
    String batchName;
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      // Satu bulan yang sama
      batchName = DateFormat('MMMM yyyy', 'id_ID').format(startDate);
    } else {
      // Lintas bulan/tahun
      String startStr = DateFormat('d MMM', 'id_ID').format(startDate);
      String endStr = DateFormat('d MMM yyyy', 'id_ID').format(endDate);
      batchName = "$startStr - $endStr";
    }

    // Menyiapkan Payload (Semua data dalam satu list)
    final payload = selectedShifts.entries.map((entry) {
      return {
        'date': DateFormat('yyyy-MM-dd').format(entry.key),
        'work_pattern_id': entry.value.id,
      };
    }).toList();

    try {
      Get.snackbar("Memproses", "Mengirim pengajuan jadwal...",
          showProgressIndicator: true,
          dismissDirection: DismissDirection.horizontal);

      // Mengirim ke Odoo (Hanya satu kali panggilan)
      await _myScheduleService.submitMonthlyRoster(payload, batchName);

      if (Get.isSnackbarOpen) Get.back();
      Get.snackbar("Berhasil", "Pengajuan jadwal berhasil dikirim.");

      // Reset & Refresh
      selectedShifts.clear();
      calendarRebuildKey.value++;

      await fetchMyRoster();
      // Refresh booked dates untuk bulan yang sedang dilihat di kalender
      await fetchBookedDatesForMonth(focusedDay.value);

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshData();
      }
    } catch (e) {
      if (Get.isSnackbarOpen) Get.back();
      Get.snackbar("Error", "Gagal mengirim pengajuan: ${e.toString()}");
    }
  }

  Future<void> cancelRequest(int rosterId) async {
    try {
      // Get.dialog dengan widget kustom
      await Get.dialog(
        CustomConfirmationDialog(
          // Memanggil widget kustom
          title: 'confirm'.tr,
          message: 'confirm_state'.tr,
          confirmText: 'confirm_cancel'.tr,
          cancelText: 'no'.tr,
          confirmButtonColor:
              Colors.red, // Mengatur warna tombol konfirmasi jika perlu
          onConfirm: () async {
            Get.back(); // Menutup dialog secara manual setelah konfirmasi
            Get.snackbar('processing'.tr, 'processing_state'.tr);
            try {
              await _myScheduleService.cancelShiftRequest(rosterId);
              Get.snackbar('success'.tr, 'success_state'.tr);
              // Memuat ulang data setelah batal
              fetchMyRoster();
              fetchBookedDatesForMonth(focusedDay.value);
            } catch (e) {
              Get.snackbar('failed'.tr, 'failed_state ${e.toString()}'.tr);
            }
          },
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      // Fallback ke snackbar jika dialog gagal
      Get.snackbar("Error", "Gagal menampilkan konfirmasi: ${e.toString()}");
    }
  }

  Future<void> _fetchAvailableShifts() async {
    try {
      isLoadingPatterns.value = true;
      final results = await _myScheduleService.getAvailableShifts();
      availablePatterns.assignAll(
        results.map((data) => WorkPattern.fromJson(data)).toList(),
      );
    } catch (e) {
      Get.snackbar('error'.tr, "error_load_shift $e".tr);
    } finally {
      isLoadingPatterns.value = false;
    }
  }

  Future<void> fetchMyRoster() async {
    rosterState.value = const DataLoading();
    try {
      final results = await _myScheduleService.getMyRoster();
      final allRosters =
          (results ?? []).map((data) => Roster.fromJson(data)).toList();

      // Filter dan Urutkan approvedSchedules
      approvedSchedules.assignAll(allRosters
          .where((r) =>
              r.status == 'Approved' &&
              r.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .toList());
      approvedSchedules.sort((a, b) => a.date.compareTo(b.date));

      // Urutkan riwayat berdasarkan tanggal terbaru dahulu
      allRosters.sort((a, b) => b.date.compareTo(a.date));
      historySchedules.assignAll(allRosters);
      // daftar bulan yang tersedia untuk filter
      final Set<DateTime> months = {};
      for (var roster in historySchedules) {
        // Simpan hanya tanggal 1 di bulan itu untuk representasi
        months.add(DateTime(roster.date.year, roster.date.month, 1));
      }
      availableHistoryMonths.assignAll(months.toList());
      rosterState.value = DataSuccess(allRosters);
    } catch (e) {
      rosterState.value = DataError(e.toString());
    }
  }

  // Metode untuk Update Filter "Jadwal Terdekat"
  void setUpcomingFilter(int days) {
    upcomingFilterDays.value = days;
    // approvedSchedules.refresh(); // Tidak perlu, getter akan otomatis update
  }

  // --- Metode untuk Update Filter "Riwayat Pengajuan ---
  void updateHistorySearch(String query) {
    historySearchQuery.value = query;
  }

  void updateHistoryMonth(DateTime? month) {
    historyMonthFilter.value = month;
  }

  void updateHistoryStatus(String status) {
    historyStatusFilter.value = status;
  }

  void openScheduleRequestForm() {
    selectedRequests.clear(); // Reset list setiap kali form dibuka
    Get.bottomSheet(
      const RequestScheduleBottomSheet(), // Menampilkan bottom sheet lama
      isScrollControlled: true,
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
    ;
  }

  void updateSelectedPattern(int index, WorkPattern pattern) {
    if (index >= 0 && index < selectedRequests.length) {
      selectedRequests[index].selectedPattern = pattern;
      selectedRequests.refresh(); // Memastikan UI terupdate
    }
  }

  bool mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    // Melakukan normalisasi DateTime saat membandingkan
    for (final aKey in a.keys) {
      dynamic normalizedAKey = aKey;
      if (aKey is DateTime) {
        normalizedAKey = DateTime(aKey.year, aKey.month, aKey.day);
      }
      // Cari key yang cocok di B setelah normalisasi
      // Gunakan firstWhereOrNull dari package:collection
      final bEntry = b.entries.firstWhereOrNull((bEntry) {
        dynamic normalizedBKey = bEntry.key;
        if (bEntry.key is DateTime) {
          final bKey = bEntry.key as DateTime;
          normalizedBKey = DateTime(bKey.year, bKey.month, bKey.day);
        }
        return normalizedAKey == normalizedBKey;
      });

      if (bEntry == null || a[aKey] != bEntry.value) {
        return false;
      }
    }
    return true;
  }
}