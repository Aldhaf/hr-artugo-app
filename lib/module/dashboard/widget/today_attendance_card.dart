import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/dashboard/controller/dashboard_controller.dart';
import 'package:hr_artugo_app/core/data_state.dart';
import 'package:intl/intl.dart';

class TodayAttendanceCard extends StatelessWidget {
  const TodayAttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Todays Attendance",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(DateFormat("d MMM, yyyy").format(DateTime.now()),
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),

            // Tampilkan Jam Shift di sini
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TAMBAHKAN KEMBALI LABEL "WORKING TIME"
                  const Text(
                    "Working Time",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),

                  // Color.fromRGBO(255, 236, 179, 1)36, 179, 1)workPatternInfo)
                  Obx(() => Text(
                        controller.workPatternInfo.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                        textAlign: TextAlign.start,
                      )),
                  const SizedBox(height: 8),

                  // TAMBAHKAN KEMBALI LOKASI SAAT INI
                  Obx(() {
                    final state = controller.locationState.value;
                    if (state is DataSuccess<String>) {
                      return _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        text: state.data,
                      );
                    }
                    if (state is DataLoading) {
                      return _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        text: "Memuat lokasi...",
                      );
                    }
                    if (state is DataError) {
                      return _buildInfoRow(
                        icon: Icons.warning_amber_outlined,
                        text: (state as DataError).error ?? "Gagal memuat lokasi",
                        color: Colors.red,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tombol Check In / Check Out
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: () {
                      // Nonaktifkan tombol jika tidak ada jadwal dan belum check-in
                      if (!controller.hasApprovedScheduleToday.value &&
                          !controller.hasCheckedInToday.value) {
                        return;
                      }

                      if (controller.hasCheckedInToday.value) {
                        controller.doCheckOut();
                      } else {
                        controller.doCheckIn();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (!controller.hasApprovedScheduleToday.value &&
                              !controller.hasCheckedInToday.value) {
                            return Colors.grey.shade400; // Warna saat nonaktif
                          }
                          return Colors.transparent;
                        },
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: controller.hasCheckedInToday.value
                              ? [
                                  Colors.red.shade400,
                                  Colors.red.shade600
                                ] // Gradasi untuk Check Out
                              : [
                                  primaryColor,
                                  const Color(0xff8f67e8)
                                ], // Gradasi untuk Check In
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              controller.hasCheckedInToday.value
                                  ? Icons.logout
                                  : Icons.login,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.hasCheckedInToday.value
                                  ? "Check Out"
                                  : "Check In",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String text, Color? color}) {
    return Row(children: [
      Icon(icon, size: 16, color: color ?? Colors.grey),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: TextStyle(color: color ?? Colors.grey, fontSize: 14),
              maxLines: 1, // Izinkan 2 baris untuk alamat yang panjang
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}
