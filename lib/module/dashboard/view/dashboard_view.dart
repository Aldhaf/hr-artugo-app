import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get; // Pastikan 'hide Get' ada
import '../controller/dashboard_controller.dart';
import '../widget/summary_card.dart';

// Import semua widget baru yang akan kita gunakan
import '../widget/user_info_header.dart';
import '../widget/today_attendance_card.dart';
import '../widget/working_hours_chart.dart';
import '../widget/dashboard_skeleton.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      // Atur warna background utama agar serasi dengan kartu
      backgroundColor: const Color(0xfff5f5f5),

      // Kita tidak lagi butuh AppBar karena header sudah menjadi bagian dari body
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const DashboardSkeleton();
          }
          return Stack(
            children: [
              // Lapisan 1: Latar Belakang Berwarna di Bagian Atas
              Container(
                height: 150, // Sesuaikan tinggi area header sesuai selera
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),

              RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                // Gunakan ListView agar seluruh konten bisa di-scroll dengan mulus
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0), // Beri sedikit jarak atas & bawah
                  children: [
                    // 1. Header Informasi Pengguna
                    const UserInfoHeader(),

                    // 2. Kartu Absensi Hari Ini
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: TodayAttendanceCard(),
                    ),

                    // 3. Ringkasan Bulanan (kita pertahankan dari UI lama)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Attendance",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          // Anda bisa menambahkan Dropdown filter bulan di sini nanti
                          Text("This Month",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() => Row(
                            children: [
                              Expanded(
                                  child: SummaryCard(
                                      title: "Present",
                                      value: "${controller.presentDays.value}",
                                      color: Colors.green.shade100,
                                      textColor: Colors.green.shade800)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: SummaryCard(
                                      title: "Late",
                                      value: "${controller.lateInDays.value}",
                                      color: Colors.orange.shade100,
                                      textColor: Colors.orange.shade800)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: SummaryCard(
                                      title: "Absent",
                                      value: "${controller.absentDays.value}",
                                      color: Colors.red.shade100,
                                      textColor: Colors.red.shade800)),
                            ],
                          )),
                    ),

                    // 4. Grafik Jam Kerja
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                      child: WorkingHoursChart(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
