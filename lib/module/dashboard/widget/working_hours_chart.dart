import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/dashboard/controller/dashboard_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

// Import model yang kita butuhkan
import 'package:hr_artugo_app/model/work_profile_model.dart'; 

class WorkingHoursChart extends StatelessWidget {
  const WorkingHoursChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil instance controller
    final controller = Get.find<DashboardController>();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Kartu
            const Text(
              "Working Hours", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 16),

            // Widget Chart
            Obx(() {
              // Jika data chart masih kosong, tampilkan pesan
              if (controller.dailyHours.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: Text("No working hour data for this period.")),
                );
              }

              // Jika data ada, tampilkan chart
              return SizedBox(
                height: 150,
                child: SfCartesianChart(
                  // Sembunyikan garis grid untuk tampilan yang lebih bersih
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    isVisible: false, // Sembunyikan sumbu Y (angka jam)
                  ),
                  // Aktifkan tooltip saat bar di-tap
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<DailyWorkHour, String>>[
                  // -----------------------------
                    ColumnSeries<DailyWorkHour, String>(
                      dataSource: controller.dailyHours,
                      xValueMapper: (DailyWorkHour data, _) => DateFormat('d MMM').format(data.date),
                      yValueMapper: (DailyWorkHour data, _) => data.hours,
                      borderRadius: BorderRadius.circular(8),
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}