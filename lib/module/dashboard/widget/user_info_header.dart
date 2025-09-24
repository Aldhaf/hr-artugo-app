import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/dashboard/controller/dashboard_controller.dart';
import 'package:hr_artugo_app/module/notification/controller/notification_controller.dart';
import 'package:intl/intl.dart';

class UserInfoHeader extends StatelessWidget {
  const UserInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final notificationC = Get.find<NotificationController>();

    // Ambil padding atas dari perangkat (untuk notch)
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      // Tambahkan topPadding ke padding yang sudah ada
      padding: EdgeInsets.fromLTRB(20.0, topPadding + 16.0, 20.0, 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Obx(() => Text(
                  controller.userName.value.isNotEmpty
                      ? controller.userName.value.substring(0, 1)
                      : "U",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                )),
          ),
          const SizedBox(width: 16),

          // Nama dan Jabatan
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.userName.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white)),
                    if (controller.jobTitle.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(controller.jobTitle.value,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14)),
                      ),
                  ],
                )),
          ),

          // --- GANTI TANGGAL DENGAN TOMBOL NOTIFIKASI ---
          IconButton(
            onPressed: () => Get.toNamed('/notifications'),
            icon: Obx(() => Badge(
                  isLabelVisible: notificationC.unreadCount.value > 0,
                  label: Text(
                    "${notificationC.unreadCount.value}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 28),
                )),
          ),
        ],
      ),
    );
  }
}
