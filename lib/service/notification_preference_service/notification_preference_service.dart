import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferenceService {
  // Method untuk memeriksa apakah sebuah tipe notifikasi diizinkan oleh pengguna
  Future<bool> isNotificationTypeEnabled(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cek dulu toggle utama "Semua Notifikasi"
    final bool allNotificationsEnabled = prefs.getBool('allNotifications') ?? true;
    if (!allNotificationsEnabled) {
      // Jika toggle utama mati, abaikan semua notifikasi
      return false;
    }

    // 2. Jika toggle utama nyala, cek toggle per tipe notifikasi
    switch (notificationType) {
      case 'checkin_reminder':
        return prefs.getBool('attendanceReminders') ?? true;
      case 'leave_approval':
        return prefs.getBool('leaveApprovals') ?? true;
      case 'announcement':
        return prefs.getBool('announcements') ?? true;
      default:
        // Jika tipe tidak dikenal, izinkan secara default
        return true;
    }
  }
}