import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:intl/intl.dart';
import '../model/my_schedule_model.dart';

class RejectedScheduleDetailSheet extends StatelessWidget {
  final Roster schedule;

  const RejectedScheduleDetailSheet({super.key, required this.schedule});

  // Helper untuk format jam
  String formatHour(double? hour) {
    if (hour == null) return '--:--';
    int h = hour.toInt();
    int m = ((hour - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Gunakan warna kartu tema
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Wrap(
        // Wrap agar tinggi sheet pas dengan konten
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'reject_details_title'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(), // Tombol tutup
              )
            ],
          ),
          const Divider(height: 24),

          // Detail Jadwal
          _buildDetailRow(
              'reject_label_date'.tr,
              DateFormat('EEEE, d MMMM yyyy', Get.locale?.languageCode)
                  .format(schedule.date)),
          _buildDetailRow('reject_label_shift'.tr, schedule.workPatternName),
          _buildDetailRow('reject_label_hours'.tr,
              "${formatHour(schedule.workFrom)} - ${formatHour(schedule.workTo)}"),
          _buildDetailRow(
              'reject_label_submitted'.tr,
              schedule.createDate != null
                  ? DateFormat('d MMM yyyy, HH:mm', Get.locale?.languageCode)
                      .format(schedule.createDate!.toLocal())
                  : '-'),
          const SizedBox(height: 16),

          // Alasan Penolakan
          Text(
            'reject_reason_header'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.rejectionReason?.isNotEmpty == true
                  ? schedule.rejectionReason!
                  : 'reject_no_reason'.tr,
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontStyle: schedule.rejectionReason?.isNotEmpty == true
                      ? FontStyle.normal
                      : FontStyle.italic),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper widget untuk baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
