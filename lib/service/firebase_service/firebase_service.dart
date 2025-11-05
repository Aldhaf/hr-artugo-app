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
        print(
            "⚠️ APNS token tidak tersedia. Ini wajar terjadi di Simulator iOS.");
      } else {
        rethrow;
      }
    }

    if (fcmToken == null) {
      print("⚠️ FCM Token is null. Skipping token save and setup listeners.");
      _setupListeners(); // Tetap setup listener agar tidak crash
      return;
    }

    print("====================================");
    print("FCM Token: $fcmToken");
    print("====================================");

    // Kirim token ke Odoo jika sesi sudah ada
    if (_odooApi.session != null) {
      try {
        await _odooApi.saveFcmToken(fcmToken);
      } catch (e) {
        print("Error saving initial FCM token: $e");
      }
    }

    // Listener untuk token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print("FCM Token Refreshed: $newToken");
      if (_odooApi.session != null) {
        _odooApi.saveFcmToken(newToken).catchError((e) {
          print("Error saving refreshed FCM token: $e");
        });
      }
    });

    _setupListeners(); // Panggil setup listener
  }

  void _setupListeners() {
    // Handler untuk background message
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // --- LISTENER GABUNGAN UNTUK FOREGROUND MESSAGE ---
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Jadikan async
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // --- Logika untuk Notifikasi Visual ---
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
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
        } else {
          print(
              "Notification type '$notificationType' is disabled by user preference.");
          // Jika notifikasi visual dimatikan, kita tetap proses data payload di bawah
        }
      }

      else {
        print(
            "Foreground message data received, but type is not 'schedule_update' or data is missing/empty.");
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
