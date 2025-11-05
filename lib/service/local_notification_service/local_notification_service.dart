import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // --- ID STATIS ---
  static const int REMINDER_NOTIFICATION_ID = 888;

  static void initialize() {
    // Pengaturan inisialisasi untuk Android & iOS
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings(
          "@drawable/ic_notification"), // Gunakan ikon yang sama
      iOS: DarwinInitializationSettings(),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      // Aksi saat notifikasi lokal ditekan
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          // Bisa menambahkan logika deep-linking jika dibutuhkan
          // Contoh: Get.toNamed('/notifications');
        }
      },
    );

    // Inisialisasi timezone
    tz.initializeTimeZones();
  }

  // Fungsi utama untuk menampilkan notifikasi
  static void showNotification(String title, String body,
      {String? payload, bool isReminder = false}) {
    int notificationId = isReminder ? 888 : DateTime.now().millisecond;

    _notificationsPlugin.show(
      notificationId, // variabel ID yang sudah disiapkan
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
