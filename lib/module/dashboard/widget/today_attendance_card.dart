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
                Text('today_attend'.tr,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(DateFormat("d MMM, yyyy").format(DateTime.now()),
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),

            // Tampilan Jam Shift
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
                  Text(
                    'working_time'.tr,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.workPatternInfo.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                        textAlign: TextAlign.start,
                      )),
                  const SizedBox(height: 8),
                  // LOKASI SAAT INI
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
                        text:
                            (state as DataError).error ?? 'failed_load_loc'.tr,
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
              child: Obx(() {
                final primaryColor = Theme.of(context)
                    .primaryColor; // Ambil warna primer di sini

                // --- KONDISI 1: TAMPILKAN PESAN "TERIMA KASIH" ---
                if (controller.showThankYouMessage.value) {
                  // ✅ Periksa showThankYouMessage
                  return ElevatedButton(
                    onPressed: null, // Tombol nonaktif
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300, // Warna abu-abu
                      foregroundColor: Colors.grey.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      // Teks dan Ikon Terima Kasih
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text('thanks_today'.tr,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }
                // --- KONDISI 2: TAMPILKAN TOMBOL CHECK OUT ---
                else if (controller.isCurrentlyCheckedIn.value) {
                  // ✅ Periksa isCurrentlyCheckedIn
                  return ElevatedButton(
                    onPressed: controller.doCheckOut, // Panggil doCheckOut
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding:
                          EdgeInsets.zero, // Biarkan Ink yang mengatur padding
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor:
                          Colors.transparent, // Buat transparan untuk gradient
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      // Gunakan Ink untuk gradient
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          // Gradient Merah
                          colors: [Colors.red.shade400, Colors.red.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Row(
                          // Teks dan Ikon Check Out
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Text('check_out'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // --- KONDISI 3: TAMPILKAN TOMBOL CHECK IN (DEFAULT) ---
                else {
                  // Cek apakah tombol Check In harus dinonaktifkan (belum ada jadwal)
                  bool isCheckInDisabled =
                      !controller.hasApprovedScheduleToday.value;

                  return ElevatedButton(
                    onPressed: isCheckInDisabled
                        ? null
                        : controller.doCheckIn, // Panggil doCheckIn atau null
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors
                          .transparent, // Buat transparan untuk gradient/warna disable
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        // Gunakan gradient ungu jika aktif, abu-abu jika nonaktif
                        gradient: isCheckInDisabled
                            ? null
                            : LinearGradient(
                                colors: [
                                  primaryColor,
                                  const Color(0xff8f67e8)
                                ], // Gunakan primaryColor
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isCheckInDisabled
                            ? Colors.grey.shade400
                            : null, // Warna disable jika tidak ada gradient
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Row(
                          // Teks dan Ikon Check In
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login,
                                color: isCheckInDisabled
                                    ? Colors.grey.shade700
                                    : Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'check_in'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCheckInDisabled
                                      ? Colors.grey.shade700
                                      : Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }),
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
              maxLines: 1, // 1 baris untuk alamat yang panjang
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}
