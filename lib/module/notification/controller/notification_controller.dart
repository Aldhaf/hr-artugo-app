import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/notification_model.dart';
import 'package:hr_artugo_app/service/notification_service/notification_service.dart';

class NotificationController extends GetxController
    with WidgetsBindingObserver {
  // --- VARIABEL STATE ---
  var isLoading = true.obs;
  var notificationList = <NotificationModel>[].obs;
  var unreadCount = 0.obs;

  final _notificationService = Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    // Mendaftarkan controller ini sebagai pengamat siklus hidup aplikasi
    WidgetsBinding.instance.addObserver(this);
    fetchNotifications();
  }

  @override
  void onClose() {
    // Selalu hapus pengamat saat controller ditutup
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Fungsi ini akan dipanggil setiap kali state aplikasi berubah (misal: dari background ke foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Jika aplikasi kembali aktif/dibuka
    if (state == AppLifecycleState.resumed) {
      // Panggil fungsi untuk mengambil data terbaru dari server
      fetchNotifications();
    }
  }

  // --- FUNGSI UNTUK MENGAMBIL DATA ---
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      // Service sudah mengembalikan List<NotificationModel>
      final parsedList = await _notificationService.getNotifications();

      notificationList.assignAll(parsedList);
      unreadCount.value = parsedList.where((n) => !n.isRead).length;
    } catch (e) {
    } finally {
      isLoading(false);
    }
  }

  // Fungsi ini khusus untuk menandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    
    final unreadIds =
        notificationList.where((n) => !n.isRead).map((n) => n.id).toList();

    if (unreadIds.isNotEmpty) {
      await _notificationService.markAllAsRead(unreadIds);

      // Setelah berhasil, panggil fetchNotifications lagi untuk refresh UI
      await fetchNotifications();
    }
  }

  Future<void> deleteNotification(int id) async {
    // Pola Optimistic UI: Hapus dari list lokal terlebih dahulu
    final int index = notificationList.indexWhere((n) => n.id == id);
    if (index == -1) return; // Tidak ditemukan, keluar

    final removedNotification = notificationList.removeAt(index);

    // Panggil API untuk menghapus di server
    final bool success = await _notificationService.deleteNotification(id);

    // Jika gagal di server, kembalikan item ke list
    if (!success) {
      notificationList.insert(index, removedNotification);
      Get.snackbar("Error", "Gagal menghapus notifikasi. Silakan coba lagi.");
    }
  }
}
