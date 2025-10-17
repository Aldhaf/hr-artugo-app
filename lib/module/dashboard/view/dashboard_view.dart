import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controller/dashboard_controller.dart';
import '../widget/summary_card.dart';
import '../model/daily_work_hour_model.dart';

// Import semua widget baru yang akan kita gunakan
import '../widget/user_info_header.dart';
import '../widget/today_attendance_card.dart';
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
                // ListView agar seluruh konten bisa di-scroll dengan mulus
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
                          DropdownButtonHideUnderline(
                            child: DropdownButton<AttendancePeriod>(
                              value: controller.selectedPeriod.value,
                              items: [
                                DropdownMenuItem(
                                  value: AttendancePeriod.thisMonth,
                                  child: Text("This Month",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                DropdownMenuItem(
                                  value: AttendancePeriod.lastMonth,
                                  child: Text("Last Month",
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  controller.changeAttendancePeriod(newValue);
                                }
                              },
                            ),
                          ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BARIS JUDUL DAN PEMILIH TANGGAL (DI LUAR CARD) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Working Hours",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Tombol untuk membuka pemilih tanggal
                              TextButton(
                                onPressed: () {
                                  // Panggil fungsi selectDateRange dari controller
                                  controller.selectDateRange(context);
                                },
                                child: Obx(() => Row(
                                      children: [
                                        Text(
                                          controller.chartDateRangeText.value,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),

                        // CARD YANG HANYA BERISI KONTEN GRAFIK ---
                        Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Obx(() {
                                  if (controller.dailyHours.isEmpty) {
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                          child: Text(
                                              "Tidak ada data untuk periode ini.")),
                                    );
                                  }

                                  // Jika data ada, barulah kita bangun chart-nya.
                                  return SizedBox(
                                    height: 200,
                                    child: SfCartesianChart(
                                      // 1. Change the axis type to DateTimeAxis
                                      primaryXAxis: DateTimeAxis(
                                        intervalType: DateTimeIntervalType.days,
                                        interval:
                                            5, // Show a label every 5 days, just like your screenshot
                                        dateFormat: DateFormat(
                                            'dd MMM'), // Let the axis format the label
                                        majorGridLines: const MajorGridLines(
                                            width:
                                                0), // Hide vertical grid lines
                                        axisLine: const AxisLine(
                                            width:
                                                0), // Hide the axis line itself
                                      ),
                                      series: <CartesianSeries>[
                                        // 2. Change the X-axis type from String to DateTime
                                        ColumnSeries<DailyWorkHour, DateTime>(
                                          dataSource: controller.dailyHours,
                                          // 3. The mapper now returns the original DateTime object
                                          xValueMapper:
                                              (DailyWorkHour data, _) =>
                                                  data.date,
                                          yValueMapper:
                                              (DailyWorkHour data, _) =>
                                                  data.hours,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      ],
                                    ),
                                  );
                                }),

                                // Ringkasan Total Jam dan Lembur
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Obx(() => _buildHourSummary(
                                          "Total Hours",
                                          controller.totalHoursSummary.value,
                                          Colors.blue,
                                        )),
                                    Obx(() => _buildHourSummary(
                                          "Overtime",
                                          controller.overtimeSummary.value,
                                          Colors.orange,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHourSummary(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
