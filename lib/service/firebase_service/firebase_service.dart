// lib/service/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:hr_artugo_app/module/notification/controller/notification_controller.dart';
import 'package:hr_artugo_app/service/local_notification_service/local_notification_service.dart';
import 'package:hr_artugo_app/service/notification_preference_service/notification_preference_service.dart';
import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';

// Fungsi ini HARUS berada di luar kelas (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class FirebaseService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _odooApi = Get.find<OdooApiService>();
  final _notificationPrefService = Get.find<NotificationPreferenceService>();

  Future<void> initialize() async {
    // 1. Minta izin dari pengguna
    await _firebaseMessaging.requestPermission();

    String? fcmToken;

    // Gunakan try-catch untuk menangani error APNS di simulator
    try {
      // Hanya coba dapatkan APNS token jika BUKAN di simulator
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // Meminta token APNS secara eksplisit
        await _firebaseMessaging.getAPNSToken();
      }
      // Dapatkan FCM token universal
      fcmToken = await _firebaseMessaging.getToken();
    } on FirebaseException catch (e) {
      // Jika error adalah 'apns-token-not-set' (kasus simulator),
      // kita tangkap, cetak peringatan, dan biarkan fcmToken tetap null.
      if (e.code == 'apns-token-not-set') {
        print(
            "⚠️ APNS token tidak tersedia. Ini wajar terjadi di Simulator iOS.");
        print(
            "⚠️ Fitur notifikasi tidak akan berfungsi, proses login dilanjutkan.");
      } else {
        // Jika ada error Firebase lain, kita lempar kembali
        rethrow;
      }
    }
    // --------------------------------

    // Jika setelah semua proses fcmToken masih null, hentikan proses notifikasi
    if (fcmToken == null) {
      _setupListeners(); // Tetap setup listener agar tidak crash di tempat lain
      return;
    }

    print("====================================");
    print("FCM Token: $fcmToken");
    print("====================================");

    if (_odooApi.session != null) {
      await _odooApi.saveFcmToken(fcmToken);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (_odooApi.session != null) {
        _odooApi.saveFcmToken(newToken);
      }
    });

    _setupListeners();
  }

  void _setupListeners() {
    // Handler untuk notifikasi yang diterima saat aplikasi di background/terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // --- PENYESUAIAN UTAMA ADA DI SINI ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // <-- Tambahkan async
      print('Got a message whilst in the foreground!');

      if (message.notification != null) {
        final String notificationType = message.data['type'] ?? 'unknown';

        // 1. Cek apakah pengguna mengizinkan tipe notifikasi ini
        final bool isEnabled =
            await _notificationPrefService.isNotificationTypeEnabled(
                notificationType);

        // 2. Jika tidak diizinkan, hentikan semua proses selanjutnya
        if (!isEnabled) {
          print(
              "Notifikasi tipe '$notificationType' diblokir oleh pengaturan pengguna.");
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
          print(
              "Notifikasi persetujuan cuti diterima, memuat ulang riwayat Time Off...");
          if (Get.isRegistered<TimeOffHistoryListController>()) {
            Get.find<TimeOffHistoryListController>().getTimeOffHistories();
          }
        }
      }
    });

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
