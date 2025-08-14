import 'package:intl/intl.dart';

enum NotificationType { announcement, leaveApproval, checkinReminder, unknown }

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;
  final NotificationType type;
  final String? relatedId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
    required this.type,
    this.relatedId,
  });

  // --- FUNGSI PENERJEMAH YANG SUDAH DIPERBAIKI ---
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk mengubah string tipe notifikasi menjadi enum
    NotificationType notificationType;
    switch (json['type']) {
      case 'leave_approval':
        notificationType = NotificationType.leaveApproval;
        break;
      case 'checkin_reminder':
        notificationType = NotificationType.checkinReminder;
        break;
      case 'announcement':
        notificationType = NotificationType.announcement;
        break;
      default:
        notificationType = NotificationType.unknown;
    }

    // Konversi tanggal yang lebih aman
    DateTime localTime;
    try {
      // Odoo mengirim waktu dalam UTC, kita konversi ke waktu lokal perangkat
      final utcTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(json['create_date'], true);
      localTime = utcTime.toLocal();
    } catch (e) {
      localTime = DateTime.now(); // Fallback jika format tanggal salah
    }

    // --- LOGIKA PALING PENTING ADA DI SINI ---
    // Logika parsing yang lebih aman untuk related_id
    String? parsedRelatedId;
    if (json['related_id'] is String) {
      parsedRelatedId = json['related_id'];
    } else if (json['related_id'] is int) {
      parsedRelatedId = json['related_id'].toString();
    }
    // Jika 'related_id' adalah 'false' atau 'null', 'parsedRelatedId' akan tetap null (aman)

    return NotificationModel(
      id: json['id'] ?? 0,
      title: json['name']?.toString() ??
          'No Title', // Odoo menggunakan 'name' untuk judul
      body: json['body']?.toString() ?? '',
      receivedAt: localTime,
      isRead: json['is_read'] ?? false,
      type: notificationType,
      relatedId:
          parsedRelatedId, // Gunakan variabel yang sudah diparsing dengan aman
    );
  }
}
