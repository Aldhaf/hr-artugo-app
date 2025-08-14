// lib/service/notification_service.dart

import 'package:hyper_ui/core.dart'; // Sesuaikan dengan path OdooApi Anda
import '../../module/notification/model/notification_model.dart'; // Impor model notifikasi

class NotificationService {
  /// Mengambil daftar notifikasi untuk pengguna yang sedang login.
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      // 1. Ambil UID dari sesi dan cek apakah ada
      final int? userId = OdooApi.session?.userId;

      // Jika tidak ada user yang login, kembalikan list kosong
      if (userId == null) {
        print("User not logged in, cannot fetch notifications.");
        return [];
      }

      // Panggil API Odoo
      var response = await OdooApi.get(
        model: "hr.notification",
        fields: [
          "id",
          "name",
          "body",
          "create_date",
          "is_read",
          "type",
          "related_id"
        ],
        // 2. Gunakan variabel userId yang sudah aman dari null
        where: [
          ['user_id', '=', userId]
        ],
        orderBy: "create_date DESC",
        limit: 50,
      );

      // Ubah data mentah dari Odoo menjadi List<NotificationModel>
      List<NotificationModel> notifications = [];
      for (var item in response) {
        notifications.add(NotificationModel(
          id: item['id'].toString(""),
          title: item['name'] ?? 'Tanpa Judul',
          body: item['body'] ?? 'Tanpa deskripsi',
          // Odoo mengembalikan tanggal dalam format UTC, kita parse
          receivedAt: DateTime.parse(item['create_date']).toLocal(),
          isRead: item['is_read'] ?? false,
          // Logika untuk mengubah string dari Odoo menjadi enum
          type: _parseNotificationType(item['type']),
          relatedId: item['related_id']?.toString(),
        ));
      }
      return notifications;
    } catch (e) {
      print("Error fetching notifications: $e");
      // Lempar error agar bisa ditangkap oleh DataState di controller
      throw Exception("Gagal mengambil data notifikasi dari server.");
    }
  }

  /// Helper untuk mengubah string dari Odoo menjadi Enum
  static NotificationType _parseNotificationType(String? typeString) {
    switch (typeString) {
      case 'leave_approval':
        return NotificationType.leaveApproval;
      case 'checkin_reminder':
        return NotificationType.checkinReminder;
      default:
        return NotificationType.announcement;
    }
  }

  // Anda juga bisa menambahkan fungsi lain di sini, seperti:
  // static Future<void> markAsRead(String id) async { ... }
  // static Future<int> getUnreadCount() async { ... }
}
