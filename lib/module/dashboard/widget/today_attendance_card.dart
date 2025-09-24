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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Working Time",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                          controller.workPatternInfo.value
                              .replaceFirst("Jam Kerja: ", ""),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (controller.locationState.value is DataSuccess<String>)
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          text: (controller.locationState.value
                                  as DataSuccess<String>)
                              .data,
                        ),
                    ],
                  )),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: () {
                      if (controller.hasCheckedInToday.value) {
                        controller.doCheckOut();
                      } else {
                        controller.doCheckIn();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets
                          .zero, // Hapus padding default untuk memberi ruang pada Ink
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      // Buat background transparan agar gradasi terlihat
                      backgroundColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
                    // Bungkus child dengan Ink untuk menampung gradasi
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

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}
