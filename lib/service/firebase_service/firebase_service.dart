import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:hr_artugo_app/module/notification/controller/notification_controller.dart';
import 'package:hr_artugo_app/service/local_notification_service/local_notification_service.dart';
import 'package:hr_artugo_app/service/notification_preference_service/notification_preference_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebaseService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _odooApi = Get.find<OdooApiService>();
  final _notificationPrefService = Get.find<NotificationPreferenceService>();

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();
    String? fcmToken;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _firebaseMessaging.getAPNSToken();
      }
      fcmToken = await _firebaseMessaging.getToken();
    } on FirebaseException catch (e) {
      if (e.code == 'apns-token-not-set') {
      } else {
        rethrow;
      }
    }

    if (fcmToken == null) {
      _setupListeners(); // Tetap setup listener agar tidak crash
      return;
    }

    // Kirim token ke Odoo jika sesi sudah ada
    if (_odooApi.session != null) {
      try {
        await _odooApi.saveFcmToken(fcmToken);
      } catch (e) {}
    }

    // Listener untuk token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      if (_odooApi.session != null) {
        _odooApi.saveFcmToken(newToken).catchError((e) {});
      }
    });

    _setupListeners(); // Panggil setup listener
  }

  void _setupListeners() {
    // Handler untuk background message
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // --- LISTENER GABUNGAN UNTUK FOREGROUND MESSAGE ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // --- Logika untuk Notifikasi Visual ---
      if (message.notification != null) {
        final String notificationType = message.data['type'] ?? 'unknown';

        // Cek preferensi notifikasi
        final bool isEnabled = await _notificationPrefService
            .isNotificationTypeEnabled(notificationType);

        if (isEnabled) {
          // Tampilkan notifikasi lokal
          bool isReminder = notificationType == 'checkin_reminder';
          LocalNotificationService.showNotification(
            message.notification!.title ?? 'No Title',
            message.notification!.body ?? 'No Body',
          );

          // Perbarui badge/list notifikasi
          if (Get.isRegistered<NotificationController>()) {
            Get.find<NotificationController>().fetchNotifications();
          }

          // Auto-refresh Time Off
          if (notificationType == 'leave_approval') {
            if (Get.isRegistered<TimeOffHistoryListController>()) {
              Get.find<TimeOffHistoryListController>().getTimeOffHistories();
            }
          }
        }
      }
    });

    // Saat pengguna menekan notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Refresh daftar notifikasi terlebih dahulu
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().fetchNotifications();
      }

      // Lakukan (deep linking)
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
