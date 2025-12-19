import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/dashboard/controller/dashboard_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../model/daily_work_hour_model.dart';

class WorkingHoursChart extends StatelessWidget {
  const WorkingHoursChart({super.key});

  @override
  Widget build(BuildContext context) {
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
            // --- Header Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Working Hours",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),

            // --- Summary Section ---
            Obx(() => _buildSummaryRow(
                  icon: Icons.timer_outlined,
                  label: "Total Hours",
                  value: controller.totalHoursSummary.value,
                  color: Colors.blue.shade700,
                )),
            const SizedBox(height: 8),
            Obx(() => _buildSummaryRow(
                  icon: Icons.more_time_outlined,
                  label: "Overtime",
                  value: controller.overtimeSummary.value,
                  color: Colors.purple.shade700,
                )),
            const SizedBox(height: 16),

            // --- Chart Section ---
            Obx(() {
              if (controller.dailyHours.isEmpty) {
                return const SizedBox(
                    height: 200, child: Center(child: Text("No data")));
              }
              return SizedBox(
                height: 200,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 10,
                    interval: 2,
                    labelFormat: '{value}h',
                    majorGridLines:
                        const MajorGridLines(dashArray: <double>[5, 5]),
                    axisLine: const AxisLine(width: 0),
                  ),
                  plotAreaBorderWidth: 0,
                  series: <CartesianSeries<DailyWorkHour, String>>[
                    ColumnSeries<DailyWorkHour, String>(
                      dataSource: controller.dailyHours,
                      width: 0.6,
                      xValueMapper: (DailyWorkHour data, _) =>
                          DateFormat('E').format(data.date),
                      yValueMapper: (DailyWorkHour data, _) {
                        if (data.status == WorkDayStatus.worked) {
                          return data.hours;
                        }
                        return 9.0;
                      },
                      pointColorMapper: (DailyWorkHour data, _) {
                        switch (data.status) {
                          case WorkDayStatus.worked:
                            return Colors.blue.shade600;
                          case WorkDayStatus.absent:
                            return Colors.pink.shade100;
                          case WorkDayStatus.holiday:
                            return Colors.grey.shade200;
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        labelAlignment: ChartDataLabelAlignment.middle,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          final dayData = data as DailyWorkHour;

                          if (dayData.status == WorkDayStatus.absent) {
                            return Transform.rotate(
                              angle: 1.5708,
                              child: const Text(
                                'Absent',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          if (dayData.status == WorkDayStatus.holiday) {
                            return Transform.rotate(
                              angle: 1.5708,
                              child: const Text(
                                'Holiday',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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

  Widget _buildSummaryRow(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
