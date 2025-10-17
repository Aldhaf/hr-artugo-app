import 'package:flutter/cupertino.dart';
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
        title: const Text('Jadwal Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMyRoster(),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- INI WIDGET CUSTOM TAB SLIDER KITA ---
          _buildCustomSlidingTab(context),

          // --- KONTEN DINAMIS (Tidak Berubah) ---
          Expanded(
            child: Obx(() {
              if (controller.selectedTabIndex.value == 0) {
                return _buildHistoryAndScheduleTab();
              } else {
                return _buildRequestScheduleTab();
              }
            }),
          ),
        ],
      ),
    );
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
            borderRadius: BorderRadius.circular(24.0), // Sangat rounded
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
                    color: Theme.of(context).primaryColor, // Warna ungu
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),

              // Teks di atasnya
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.transparent),
                      onPressed: () => controller.changeTabIndex(0),
                      child: Text(
                        'Riwayat & Jadwal',
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
                        'Ajukan Jadwal',
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

  // --- WIDGET UNTUK KONTEN TAB 1 ---
  Widget _buildHistoryAndScheduleTab() {
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Jadwal Terdekat"),
          const SizedBox(height: 12),
          if (controller.approvedSchedules.isEmpty)
            _EmptyStateCard(
                icon: Icons.calendar_today,
                message: "Tidak ada jadwal yang disetujui dalam waktu dekat.")
          else
            ...controller.approvedSchedules
                .map((schedule) => _buildScheduleCard(schedule)),
          const SizedBox(height: 24),
          _buildSectionHeader("Riwayat Pengajuan"),
          const SizedBox(height: 12),
          if (controller.historySchedules.isEmpty)
            _EmptyStateCard(
                icon: Icons.history,
                message: "Anda belum pernah mengajukan jadwal.")
          else
            ...controller.historySchedules
                .map((history) => _buildScheduleCard(history)),
        ],
      );
    });
  }

  // --- WIDGET UNTUK KONTEN (KALENDER) ---
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
            // Iterasi melalui kunci map dan gunakan isSameDay untuk menemukan match
            final statusEntry =
                controller.bookedDatesWithStatus.entries.firstWhere(
              (entry) => isSameDay(entry.key, day),
              orElse: () => MapEntry(
                  DateTime(0), ''), // Kembalikan null jika tidak ada match
            );
            // Hanya aktifkan jika statusnya BUKAN 'approved'
            return statusEntry.value != 'approved';
          },
          calendarBuilders: CalendarBuilders(
            // --- BUILDER INI UNTUK MENGUBAH WARNA ---
            disabledBuilder: (context, day, focusedDay) {
              // Gunakan logika yang sama untuk menemukan status
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
            child: const Text("Kirim Pengajuan Jadwal"),
          ),
        ),
      ]));
    });
  }

  // --- HELPER WIDGETS ---
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

  Widget _buildScheduleInfoCard(Roster schedule) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available, color: Colors.green),
        title: Text(schedule.workPatternName),
        subtitle: Text(DateFormat('EEEE, d MMMM yyyy').format(schedule.date)),
      ),
    );
  }

  Widget _buildScheduleCard(Roster schedule) {
    final controller = Get.find<MyScheduleController>();

    // Tentukan warna berdasarkan status
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

    // Helper untuk format jam dari float (misal: 8.5 -> "08:30")
    String formatHour(double? hour) {
      if (hour == null) return '--:--';
      int h = hour.toInt();
      int m = ((hour - h) * 60).round();
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    }

    return Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip
            .antiAlias, // Penting agar side bar tidak keluar dari border radius
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
                          schedule.status.toUpperCase(),
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
                        "${DateFormat('EEEE, d MMMM yyyy').format(schedule.date)}  •  ${formatHour(schedule.workFrom)} - ${formatHour(schedule.workTo)}",
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const Divider(height: 24),
                      // Detail Pengajuan
                      if (schedule.createDate != null)
                        Text(
                          "Diajukan: ${DateFormat('d MMM yyyy, HH:mm').format(schedule.createDate!)}",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      if (schedule.rejectionReason != null &&
                          schedule.rejectionReason!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Alasan: ${schedule.rejectionReason}",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Tombol Aksi (Kondisional)
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
                            child: const Text("CANCEL REQUEST"),
                          ),
                        ),
                      if (schedule.status == 'Rejected')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              /* Logika untuk lihat detail/ajukan ulang */
                            },
                            child: const Text("DETAIL"),
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
      color: Colors.grey[100],
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
