import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/my_schedule/model/work_pattern_model.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller/my_schedule_controller.dart';
import '../model/my_schedule_model.dart';
import '../../../core/data_state.dart';

class MyScheduleView extends GetView<MyScheduleController> {
  const MyScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_schedule_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchMyRoster();
              controller.fetchBookedDatesForMonth(controller.focusedDay.value);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget Tab Kustom
          _buildCustomSlidingTab(context),

          Expanded(
            child: Obx(() {
              if (controller.selectedTabIndex.value == 0) {
                return _buildHistoryAndScheduleTab(context);
              } else {
                return _buildRequestScheduleTab();
              }
            }),
          ),
        ],
      ),
    );
  }

  String _formatHour(double? hour) {
    if (hour == null) return '--:--';
    int h = hour.toInt();
    int m = ((hour - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  Widget _buildCustomSlidingTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Obx(() {
        // Lebar untuk setiap "pil"
        double pillWidth = (Get.width - 32) /
            2; // (Lebar layar - total padding horizontal) / jumlah tab

        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Stack(
            children: [
              // "Pil" aktif yang bergeser
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                // Geser ke kiri (Alignment -1.0) atau kanan (Alignment 1.0)
                alignment: controller.selectedTabIndex.value == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: pillWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.transparent),
                      onPressed: () => controller.changeTabIndex(0),
                      child: Text(
                        'tab_history'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // Ganti warna teks berdasarkan tab yang aktif
                          color: controller.selectedTabIndex.value == 0
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.transparent),
                      onPressed: () => controller.changeTabIndex(1),
                      child: Text(
                        'tab_request'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // Ganti warna teks berdasarkan tab yang aktif
                          color: controller.selectedTabIndex.value == 1
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // Widget untuk konten tab Riwayat & Jadwal Terdekat
  Widget _buildHistoryAndScheduleTab(context) {
    return Obx(() {
      // Obx utama untuk state loading/error
      final state = controller.rosterState.value;

      if (state is DataLoading && controller.historySchedules.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is DataError) {
        final errorState = state as DataError;
        return Center(
            child: Text("Error: ${errorState.error ?? 'Unknown error'}"));
      }

      // Gunakan ListView untuk menampung semua section
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Bagian Jadwal Terdekat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSectionHeader("section_upcoming".tr),
              Obx(() {
                final primaryColor = Theme.of(context).primaryColor;

                return Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      // Shadow halus
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Chip "Upcoming"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(18),
                                right: Radius.circular(18)),
                          ),
                          child: Center(
                            child: Text(
                              "upcoming_chip".tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        // Dropdown Hari
                        Container(
                          padding: const EdgeInsets.only(left: 8, right: 4),
                          child: DropdownButton<int>(
                            value: controller.upcomingFilterDays.value,
                            underline: const SizedBox(),
                            isDense: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: const Color(0xFFB366FF),
                              size: 18,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF8A4FFF),
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                            ),
                            dropdownColor: Colors.white,
                            items: [
                              DropdownMenuItem(
                                  value: 3, child: Text("filter_days_3".tr)),
                              DropdownMenuItem(
                                  value: 7, child: Text("filter_days_7".tr)),
                              DropdownMenuItem(
                                  value: 30, child: Text("filter_days_30".tr)),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                controller.setUpcomingFilter(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            // Gunakan getter baru yang sudah difilter
            final list = controller.filteredApprovedSchedules;
            if (list.isEmpty) {
              return _EmptyStateCard(
                  icon: Icons.calendar_today,
                  message: "empty_upcoming".trParams({
                    'days': controller.upcomingFilterDays.value.toString()
                  }));
            } else {
              // Gunakan Column agar tidak error constraint di dalam ListView
              return Column(
                children: list
                    .map((schedule) => _buildScheduleCard(schedule))
                    .toList(),
              );
            }
          }),

          const SizedBox(height: 24),

          // Bagian Riwayat Pengajuan
          _buildSectionHeader("section_history".tr),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Latar putih
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) => controller.updateHistorySearch(value),
              decoration: InputDecoration(
                hintText: "search_hint".tr,
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    size: 20, color: Theme.of(context).primaryColor),
                // Hapus warna dan border dari TextField agar transparan
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                border: InputBorder.none, // Hapus border
                enabledBorder: InputBorder.none, // Hapus border
                focusedBorder: InputBorder.none, // Hapus border
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dropdown Bulan & Status
          Row(
            children: [
              // Dropdown Bulan
              Expanded(
                flex: 2, // Beri rasio lebih besar untuk bulan
                child: Obx(() => _buildFilterDropdown<DateTime?>(
                      // Gunakan helper
                      value: controller.historyMonthFilter.value,
                      hint: "filter_all_months".tr, // Contoh hint
                      items: [
                        // Item untuk "All Month" (null)
                        DropdownMenuItem<DateTime?>(
                          value: null,
                          child: Text("filter_all_months".tr,
                              style: TextStyle(fontSize: 14)),
                        ),
                        // Item untuk setiap bulan yang ada di riwayat
                        ...controller.availableHistoryMonths.map((month) {
                          return DropdownMenuItem<DateTime?>(
                            value: month,
                            child: Text(
                                DateFormat('MMMM yyyy', 'id_ID').format(month),
                                style: const TextStyle(fontSize: 14)),
                          );
                        }),
                      ],
                      onChanged: (value) =>
                          controller.updateHistoryMonth(value),
                    )),
              ),
              const SizedBox(width: 12),
              // Dropdown Status
              Expanded(
                flex: 1, // Beri rasio lebih kecil untuk status
                child: Obx(() => _buildFilterDropdown<String>(
                      // Gunakan helper
                      value: controller.historyStatusFilter.value,
                      hint:
                          "filter_status_label".tr, // Hint tidak akan terpakai
                      items: [
                        DropdownMenuItem(
                            value: 'All',
                            child: Text("status_all".tr,
                                style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(
                            value: 'Approved',
                            child: Text("status_approved".tr,
                                style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(
                            value: 'Requested',
                            child: Text("status_requested".tr,
                                style: TextStyle(fontSize: 14))),
                        DropdownMenuItem(
                            value: 'Rejected',
                            child: Text("status_rejected".tr,
                                style: TextStyle(fontSize: 14))),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          controller.updateHistoryStatus(value);
                      },
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daftar Hasil Filter (Menggantikan ExpansionTile)
          Obx(() {
            // Gunakan getter baru yang sudah difilter
            final list = controller.filteredHistorySchedules;
            if (list.isEmpty) {
              return _EmptyStateCard(
                  icon: Icons.search_off, message: "empty_history".tr);
            }
            return Column(
              children:
                  list.map((history) => _buildScheduleCard(history)).toList(),
            );
          }),
        ],
      );
    });
  }

  // Widget untuk konten kalender di tab Request Schedule
  Widget _buildRequestScheduleTab() {
    return Obx(() {
      return SingleChildScrollView(
          child: Column(children: [
        TableCalendar<WorkPattern>(
          key: ValueKey(controller.calendarRebuildKey.value),
          firstDay: DateTime.now(),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay.value,
          calendarFormat: controller.calendarFormat.value,
          selectedDayPredicate: (day) =>
              controller.selectedShifts.keys.any((d) => isSameDay(d, day)),
          onDaySelected: controller.onDaySelected,
          onFormatChanged: (format) => controller.calendarFormat.value = format,
          onPageChanged: (focusedDay) {
            controller.focusedDay.value = focusedDay;
            controller.fetchBookedDatesForMonth(focusedDay);
          },
          eventLoader: controller.getEventsForDay,
          enabledDayPredicate: (day) {
            // Iterasi melalui key map dan menggunakan isSameDay untuk menemukan match
            final statusEntry =
                controller.bookedDatesWithStatus.entries.firstWhere(
              (entry) => isSameDay(entry.key, day),
              orElse: () => MapEntry(
                  DateTime(0), ''), // Mengembalikan null jika tidak ada match
            );
            // Hanya aktifkan jika statusnya BUKAN 'approved'
            return statusEntry.value != 'approved';
          },
          calendarBuilders: CalendarBuilders(
            // Builder untuk tanggal yang dinonaktifkan
            disabledBuilder: (context, day, focusedDay) {
              // logika untuk menemukan status
              final statusEntry =
                  controller.bookedDatesWithStatus.entries.firstWhere(
                (entry) => isSameDay(entry.key, day),
                orElse: () => MapEntry(DateTime(0), ''),
              );

              // Jika tanggal dinonaktifkan (karena sudah 'approved'),
              // beri warna latar abu-abu.
              if (statusEntry.value == 'approved') {
                return Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                    right: 1, bottom: 1, child: _buildEventsMarker(events));
              }
              return null;
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            onPressed: controller.submitScheduleRequest,
            child: Text("btn_submit_request".tr),
          ),
        ),
      ]));
    });
  }

  // HELPER WIDGETS
  Widget _buildEventsMarker(List<WorkPattern> events) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.blue.shade400,
          borderRadius: BorderRadius.circular(12.0)),
      child: Text(events.first.name.substring(0, 1),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildFilterDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: Theme.of(Get.context!).primaryColor, size: 20),
          items: items,
          onChanged: onChanged,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Roster schedule) {
    // final controller = Get.find<MyScheduleController>();

    // Menentukan warna berdasarkan status
    final Color statusColor;
    switch (schedule.status) {
      case 'Approved':
        statusColor = const Color(0xff50B428); // Hijau
        break;
      case 'Requested':
        statusColor = const Color(0xffFFBF00); // Kuning
        break;
      case 'Rejected':
        statusColor = const Color(0xffD92D20); // Merah
        break;
      default:
        statusColor = Colors.grey;
    }

    String statusText;
    switch (schedule.status) {
      case 'Approved':
        statusText = 'schedule_status_approved'.tr; // "DISETUJUI"
        break;
      case 'Requested':
        statusText = 'schedule_status_requested'.tr; // "DIAJUKAN"
        break;
      case 'Rejected':
        statusText = 'schedule_status_rejected'.tr; // "DITOLAK"
        break;
      default:
        statusText = schedule.status.toUpperCase();
    }

    return Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        clipBehavior:
            Clip.antiAlias, // agar side bar tidak keluar dari border radius
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Side Bar Berwarna
              Container(
                width: 9,
                color: statusColor,
              ),
              // Konten utama
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Nama Shift
                      Text(
                        schedule.workPatternName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      // Tanggal dan Jam
                      Text(
                        // Menggunakan Get.locale?.languageCode agar mengikuti bahasa aplikasi (id/en)
                        "${DateFormat('EEEE, d MMMM yyyy', Get.locale?.languageCode).format(schedule.date)}  •  ${_formatHour(schedule.workFrom)} - ${_formatHour(schedule.workTo)}",
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const Divider(height: 24),
                      // Detail Pengajuan
                      if (schedule.createDate != null)
                        Text(
                          'schedule_submitted_on'.trParams({
                            'date': DateFormat('d MMM yyyy, HH:mm',
                                    Get.locale?.languageCode)
                                .format(schedule.createDate!.toLocal())
                          }),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      if (schedule.rejectionReason != null &&
                          schedule.rejectionReason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'schedule_reason'.trParams(
                                {'reason': schedule.rejectionReason!}),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Tombol Aksi
                      if (schedule.status == 'Requested')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                controller.cancelRequest(schedule.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: Text("btn_cancel".tr),
                          ),
                        ),
                      if (schedule.status == 'Rejected')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              controller.showRejectionDetail(schedule);
                            },
                            child: Text("btn_detail".tr),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(Get.context!).cardColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(message, style: TextStyle(color: Colors.grey[600]))),
          ],
        ),
      ),
    );
  }
}
