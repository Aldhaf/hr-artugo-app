import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../widget/summary_card.dart';
import '../model/daily_work_hour_model.dart';

import '../widget/user_info_header.dart';
import '../widget/today_attendance_card.dart';
import '../widget/dashboard_skeleton.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        top: false,
        child: Obx(() {
          // --- TAMPILKAN UI BERDASARKAN STATUS ---
          switch (controller.status.value) {
            case DashboardStatus.loading:
              // Tampilkan skeleton hanya jika loading data baru dan tidak ada data cache
              return controller.isShowingCachedData.value
                  ? _buildDashboardContent(context, controller,
                      isLoading: true) // Tampilkan konten + loading indicator
                  : const DashboardSkeleton();
            case DashboardStatus.success:
            case DashboardStatus
                  .offline: // Tampilkan konten juga saat offline (jika ada cache)
              return _buildDashboardContent(context, controller);
            case DashboardStatus.error:
              return _buildErrorState(context, controller);
          }
        }),
      ),
    );
  }

  // Membangun konten utama dasbor
  Widget _buildDashboardContent(
      BuildContext context, DashboardController controller,
      {bool isLoading = false}) {
    return Stack(
      children: [
        // --- Latar Belakang Header ---
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // --- Konten Scrollable dengan Pull-to-Refresh ---
        RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: [
              // --- BANNER OFFLINE/CACHE ---
              if (controller.status.value == DashboardStatus.offline ||
                  controller.isShowingCachedData.value)
                _buildOfflineCacheBanner(controller),

              // --- User Info Header ---
              const UserInfoHeader(),

              // --- Kartu Absensi Hari Ini ---
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                child: TodayAttendanceCard(),
              ),

              // --- Ringkasan Bulanan ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('dashboard_total_attendance'.tr,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 180,
                      height: 36,
                      child: Obx(() => Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(18)),
                            child: Row(
                              children: [
                                _buildSegmentOption(
                                    context,
                                    'dashboard_last_month'.tr,
                                    controller.selectedPeriod.value ==
                                        AttendancePeriod.lastMonth,
                                    () => controller.changeAttendancePeriod(
                                        AttendancePeriod.lastMonth)),
                                _buildSegmentOption(
                                    context,
                                    'dashboard_this_month'.tr,
                                    controller.selectedPeriod.value ==
                                        AttendancePeriod.thisMonth,
                                    () => controller.changeAttendancePeriod(
                                        AttendancePeriod.thisMonth)),
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Obx(() => Row(
                      children: [
                        Expanded(
                            child: SummaryCard(
                                title: 'dashboard_present'.tr,
                                value: "${controller.presentDays.value}",
                                color: Colors.green.shade100,
                                textColor: Colors.green.shade800)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: SummaryCard(
                                title: 'dashboard_late'.tr,
                                value: "${controller.lateInDays.value}",
                                color: Colors.orange.shade100,
                                textColor: Colors.orange.shade800)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: SummaryCard(
                                title: 'dashboard_absent'.tr,
                                value: "${controller.absentDays.value}",
                                color: Colors.red.shade100,
                                textColor: Colors.red.shade800)),
                      ],
                    )),
              ),

              // --- Grafik Jam Kerja ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('dashboard_working_hours'.tr,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () =>
                              _showDateRangePickerSheet(context, controller),
                          child: Obx(() => Row(
                                children: [
                                  Text(controller.chartDateRangeText.value,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold)),
                                  Icon(Icons.arrow_drop_down,
                                      color: Theme.of(context).primaryColor),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Obx(() {
                            // --- TAMPILKAN LOADING ATAU CHART ---
                            if (controller.isChartLoading.value) {
                              return const SizedBox(
                                height: 200,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            } else if (controller.dailyHours.isEmpty) {
                              return SizedBox(
                                  height: 200,
                                  child: Center(
                                      child: Text('dashboard_no_data'.tr)));
                            } else {
                              // --- KONFIGURASI CHART ---
                              return SizedBox(
                                height: 200,
                                child: SfCartesianChart(
                                  primaryXAxis: DateTimeAxis(
                                    // DateTimeAxis untuk sumbu X
                                    dateFormat: DateFormat(
                                        'd MMM'), // Format tanggal di sumbu X
                                    intervalType: DateTimeIntervalType.days,
                                    majorGridLines: const MajorGridLines(
                                        width:
                                            0), // Menghilangkan grid vertikal
                                  ),
                                  primaryYAxis: const NumericAxis(
                                    majorTickLines: MajorTickLines(
                                        size:
                                            0), // Menghilangkan tick di sumbu Y
                                    labelFormat:
                                        '{value}h', // Menambahkan 'h' setelah angka jam
                                    minimum: 0, // Mulai dari 0 jam
                                  ),
                                  series: <CartesianSeries>[
                                    // --- Menggunakan ColumnSeries untuk grafik batang ---
                                    ColumnSeries<DailyWorkHour, DateTime>(
                                      dataSource: controller.dailyHours
                                          .toList(), // Mengambil data dari controller
                                      xValueMapper: (DailyWorkHour data, _) =>
                                          data.date,
                                      yValueMapper: (DailyWorkHour data, _) =>
                                          data.hours,
                                      // Mengatur warna batang
                                      pointColorMapper:
                                          (DailyWorkHour data, _) {
                                        if (data.status ==
                                                WorkDayStatus.absent ||
                                            data.hours == 0) {
                                          return Colors.grey.shade300;
                                        }
                                        return Theme.of(context)
                                            .primaryColor; // Warna default
                                      },
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6)), // Sudut membulat
                                      width: 0.6, // Lebar batang
                                    )
                                  ],
                                  tooltipBehavior: TooltipBehavior(
                                      enable: true), // Aktifkan tooltip
                                ),
                              );
                            }
                          }),
                          const SizedBox(height: 16),
                          // --- Ringkasan Total Jam & Lembur ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Obx(() => _buildHourSummary(
                                    'dashboard_total_hours'.tr,
                                    controller.totalHoursSummary.value,
                                    Theme.of(context)
                                        .primaryColor, // Default color
                                  )),
                              Obx(() => _buildHourSummary(
                                    'dashboard_overtime'.tr,
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

        // --- Indikator Loading di Atas ---
        if (isLoading)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white))),
                    SizedBox(width: 12),
                    Text('dashboard_loading_data'.tr,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Membangun UI untuk state error
  Widget _buildErrorState(
      BuildContext context, DashboardController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
            const SizedBox(height: 16),
            const Text("Oops!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value ?? 'dashboard_error_loading'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text('dashboard_try_again'.tr),
              onPressed: () => controller.refreshData(),
            )
          ],
        ),
      ),
    );
  }

  // Membangun banner indikator offline atau cache
  Widget _buildOfflineCacheBanner(DashboardController controller) {
    String message;
    Color backgroundColor;
    IconData icon;

    if (controller.status.value == DashboardStatus.offline) {
      message = controller.isShowingCachedData.value
          ? 'dashboard_offline_cache_msg'.tr
          : 'dashboard_offline_msg'.tr;
      backgroundColor = Colors.orange.shade700;
      icon = Icons.wifi_off;
    } else {
      message = 'dashboard_cache_msg'.tr;
      backgroundColor = Colors.blueGrey.shade600;
      icon = Icons.cloud_off;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showDateRangePickerSheet(
      BuildContext context, DashboardController controller) {
    Get.bottomSheet(
      _DateRangePickerSheet(
        initialRange: DateTimeRange(
          start: controller.chartStartDate.value,
          end: controller.chartEndDate.value,
        ),
        onApply: (picked) {
          controller.applyDateRange(picked);
        },
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
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

  Widget _buildSegmentOption(
    BuildContext context,
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Animasi untuk transisi warna yang mulus
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget stateful kustom untuk Bottom Sheet pemilih rentang tanggal.
class _DateRangePickerSheet extends StatefulWidget {
  final DateTimeRange initialRange;
  final Function(DateTimeRange?) onApply;

  const _DateRangePickerSheet({
    required this.initialRange,
    required this.onApply,
  });

  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  late DateTime _focusedDay;
  late DateTime? _rangeStart;
  late DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialRange.start;
    _rangeStart = widget.initialRange.start;
    _rangeEnd = widget.initialRange.end;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'dashboard_pick_date_range'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime(2023),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.toggledOn,

            // Logika saat pengguna memilih rentang
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _rangeStart = start;
                _rangeEnd = end;
              });
            },
            // Styling sesuai tema
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              rangeHighlightColor: primaryColor.withOpacity(0.2),
              rangeStartDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              if (_rangeStart != null) {
                widget.onApply(DateTimeRange(
                    start: _rangeStart!, end: _rangeEnd ?? _rangeStart!));
              } else {
                widget.onApply(null);
              }
            },
            child: Text('dashboard_apply'.tr),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
