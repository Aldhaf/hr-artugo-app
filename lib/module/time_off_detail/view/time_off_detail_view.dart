import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/time_off_detail_controller.dart';

class TimeOffDetailView extends StatelessWidget {
  const TimeOffDetailView({super.key});

  // Helper untuk memformat tanggal dengan aman
  String _formatDate(dynamic dateValue) {
    if (dateValue == null || dateValue is! String) {
      return "N/A";
    }
    try {
      DateTime date;
      // Parse dengan format 'yyyy-MM-dd' terlebih dahulu
      if (dateValue.length == 10) {
        date = DateFormat('yyyy-MM-dd').parse(dateValue);
      } else {
        // Jika tidak, coba parse dengan format 'yyyy-MM-dd HH:mm:ss'
        date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateValue);
      }
      // Format menjadi "dd MMMM yyyy" (contoh: 30 Juli 2025)
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      // Kembalikan string asli jika semua format gagal
      return dateValue;
    }
  }

  // Helper untuk status agar lebih informatif
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String label;

    switch (status) {
      case 'validate':
        backgroundColor = const Color.fromRGBO(76, 175, 80, 1);
        label = 'Approved';
        break;
      case 'refuse':
        backgroundColor = Colors.red;
        label = 'Refused';
        break;
      case 'confirm':
        backgroundColor = Colors.blue;
        label = 'To Approve';
        break;
      default:
        backgroundColor = Colors.grey;
        label = 'Draft';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimeOffDetailController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Cuti"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.timeOffData.value == null) {
          return const Center(child: Text("Data tidak ditemukan."));
        }

        final data = controller.timeOffData.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Deskripsi: ${data['display_name'] ?? ''}",
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 24.0),
                  _buildDetailTile(
                    icon: Icons.category_outlined,
                    title: "Tipe Cuti",
                    // Ambil nama dari list, contoh: [1, "Unpaid"] -> "Unpaid"
                    subtitle: data['holiday_status_id']?[1] ?? 'N/A',
                  ),
                  _buildDetailTile(
                    icon: Icons.date_range_outlined,
                    title: "Dari Tanggal",
                    subtitle: _formatDate(data['date_from']),
                  ),
                  _buildDetailTile(
                    icon: Icons.date_range_outlined,
                    title: "Sampai Tanggal",
                    subtitle: _formatDate(data['date_to']),
                  ),
                  _buildDetailTile(
                    icon: Icons.timer_outlined,
                    title: "Durasi",
                    subtitle: "${data['number_of_days'] ?? '0'} hari",
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: Colors.deepPurple),
                    title: const Text("Status",
                        style: TextStyle(color: Colors.grey)),
                    trailing: _buildStatusChip(data['state'] ?? ''),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Widget helper untuk membuat baris detail yang konsisten
  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
            fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }
}
