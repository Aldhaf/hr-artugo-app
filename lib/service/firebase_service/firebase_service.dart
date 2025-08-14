// lib/service/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get; // Untuk OdooApi
import 'package:hyper_ui/module/notification/controller/notification_controller.dart';
import 'package:hyper_ui/service/local_notification_service/local_notification_service.dart';
import 'package:hyper_ui/service/notification_preference_service/notification_preference_service.dart';

// Fungsi ini HARUS berada di luar kelas (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class FirebaseService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Minta izin dari pengguna (iOS & Android 13+)
    await _firebaseMessaging.requestPermission();

    // 2. Dapatkan FCM Token dan kirim ke server
    final fcmToken = await _firebaseMessaging.getToken();
    print("====================================");
    print("FCM Token: $fcmToken"); // Anda akan butuh ini untuk tes
    print("====================================");

    if (fcmToken != null && OdooApi.session != null) {
      await OdooApi.saveFcmToken(fcmToken);
    }

    // Dengarkan jika token diperbarui oleh Firebase
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (OdooApi.session != null) {
        OdooApi.saveFcmToken(newToken);
      }
    });

    // 3. Setup listener untuk notifikasi
    _setupListeners();
  }

  void _setupListeners() {
    // Handler untuk notifikasi yang diterima saat aplikasi di background/terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // --- PENYESUAIAN UTAMA ADA DI SINI ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async { // <-- Tambahkan async
      print('Got a message whilst in the foreground!');
      
      if (message.notification != null) {
        final String notificationType = message.data['type'] ?? 'unknown';

        // 1. Cek apakah pengguna mengizinkan tipe notifikasi ini
        final bool isEnabled = await NotificationPreferenceService.isNotificationTypeEnabled(notificationType);

        // 2. Jika tidak diizinkan, hentikan semua proses selanjutnya
        if (!isEnabled) {
          print("Notifikasi tipe '$notificationType' diblokir oleh pengaturan pengguna.");
          return;
        }

        // 3. Jika diizinkan, lanjutkan semua proses yang sudah Anda miliki
        bool isReminder = notificationType == 'checkin_reminder';
        LocalNotificationService.showNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No Body',
          isReminder: isReminder,
        );

        // Perbarui riwayat notifikasi & badge
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications();
        }

        // Auto-refresh halaman Time Off jika relevan
        if (notificationType == 'leave_approval') {
          print("Notifikasi persetujuan cuti diterima, memuat ulang riwayat Time Off...");
          if (Get.isRegistered<TimeOffHistoryListController>()) {
            Get.find<TimeOffHistoryListController>().getTimeOffHistories();
          }
        }
      }
    });

    // --- PERUBAHAN DI SINI ---
    // Saat PENGGUNA MENEKAN notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notifikasi ditekan dengan data: ${message.data}');

      // Refresh daftar notifikasi terlebih dahulu
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().fetchNotifications();
      }

      // Lakukan navigasi cerdas (deep linking)
      final String? type = message.data['type'];
      final String? id = message.data['id'];

      if (type == 'leave_approval' && id != null) {
        Get.toNamed('/time_off_detail', arguments: id);
      } else {
        Get.toNamed('/notifications');
      }
    });
  }
}
