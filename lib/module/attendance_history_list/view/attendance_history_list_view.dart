import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class AttendanceHistoryListView extends StatelessWidget {
  const AttendanceHistoryListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceHistoryListController>();
    final primaryColor = Theme.of(context).primaryColor;

    // Fungsi untuk memformat waktu (AM/PM)
    String formatTime(dynamic timeValue) {
      if (timeValue == null || timeValue == false) return "--:--:--";
      DateTime date = DateTime.parse(timeValue.toString() + "Z").toLocal();
      return DateFormat("HH:mm:ss").format(date);
    }

    // Fungsi untuk memformat tanggal
    String formatDate(dynamic timeValue) {
      if (timeValue == null || timeValue == false) return 'history_no_date'.tr;
      DateTime date = DateTime.parse(timeValue.toString() + "Z").toLocal();
      return DateFormat("MMMM d, yyyy", Get.locale?.languageCode).format(date);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('history_attendance_title'.tr),
        elevation: 0.6,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return Center(child: Text('history_empty'.tr));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            var item = controller.items[index];

            var date = formatDate(item["check_in"]);
            var checkIn = formatTime(item["check_in"]);
            var checkOut = formatTime(item["check_out"]);

            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                // Membuat semua anak Row memiliki tinggi yang sama
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bagian Tanggal
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24.0),
                            // Bagian Waktu Check In & Check Out
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTimeInfo(
                                  label: 'history_check_in'.tr,
                                  time: checkIn,
                                  icon: Icons.arrow_forward,
                                  color: Colors.green,
                                ),
                                _buildTimeInfo(
                                  label: 'history_check_out'.tr,
                                  time: checkOut,
                                  icon: Icons.arrow_back,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Widget helper untuk membuat tampilan jam
  Widget _buildTimeInfo({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
