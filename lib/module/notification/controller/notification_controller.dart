// lib/module/notification/controller/notification_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/notification_model.dart';
import '../../../shared/util/odoo_api/odoo_api.dart'; // Impor service API Anda

class NotificationController extends GetxController
    with WidgetsBindingObserver {
  // --- TAMBAHKAN VARIABEL STATE DI SINI ---
  var isLoading = true.obs;
  var notificationList = <NotificationModel>[].obs;
  var unreadCount = 0.obs; // Untuk badge di dashboard

  @override
  void onInit() {
    super.onInit();
    // Daftarkan controller ini sebagai pengamat siklus hidup aplikasi
    WidgetsBinding.instance.addObserver(this);
    fetchNotifications();
  }

  @override
  void onClose() {
    // Selalu hapus pengamat saat controller ditutup
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // --- LOGIKA UTAMA ADA DI SINI ---
  // Fungsi ini akan dipanggil setiap kali state aplikasi berubah (misal: dari background ke foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Jika aplikasi kembali aktif/dibuka
    if (state == AppLifecycleState.resumed) {
      print("Aplikasi kembali aktif, memuat ulang notifikasi...");
      // Panggil fungsi untuk mengambil data terbaru dari server
      fetchNotifications();
    }
  }

  // --- TAMBAHKAN FUNGSI UNTUK MENGAMBIL DATA ---
  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      // Panggil fungsi API yang sudah kita buat sebelumnya
      final results = await OdooApi.fetchNotifications();
      // Ubah data mentah dari API menjadi list model
      final parsedList =
          results.map((json) => NotificationModel.fromJson(json)).toList();

      notificationList.assignAll(parsedList);
      // Logika ini sekarang sudah benar, ia hanya menghitung
      unreadCount.value = parsedList.where((n) => !n.isRead).length;
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      isLoading(false);
    }
  }

  // Fungsi ini khusus untuk menandai semua notifikasi sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    print("Menandai semua notifikasi sebagai sudah dibaca...");
    final unreadIds =
        notificationList.where((n) => !n.isRead).map((n) => n.id).toList();

    if (unreadIds.isNotEmpty) {
      await OdooApi.markNotificationsAsRead(unreadIds);
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
    final bool success = await OdooApi.deleteNotification(id);

    // Jika gagal di server, kembalikan item ke list
    if (!success) {
      notificationList.insert(index, removedNotification);
      Get.snackbar("Error", "Gagal menghapus notifikasi. Silakan coba lagi.");
    }
  }
}
