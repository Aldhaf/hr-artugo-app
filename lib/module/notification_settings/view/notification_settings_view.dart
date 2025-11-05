import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notification_settings_controller.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
      ),
      body: Obx(
        () => ListView(
          children: [
            SwitchListTile(
              title: const Text("Semua Notifikasi"),
              subtitle: const Text("Aktifkan atau nonaktifkan semua notifikasi"),
              value: controller.allNotifications.value,
              onChanged: (value) => controller.updateSetting('allNotifications', value),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text("Pengingat Absensi"),
              subtitle: const Text("Notifikasi harian untuk check-in dan check-out"),
              value: controller.attendanceReminders.value,
              onChanged: controller.allNotifications.value
                  ? (value) => controller.updateSetting('attendanceReminders', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text("Persetujuan Cuti"),
              subtitle: const Text("Saat cuti disetujui atau ditolak"),
              value: controller.leaveApprovals.value,
              onChanged: controller.allNotifications.value
                  ? (value) => controller.updateSetting('leaveApprovals', value)
                  : null,
            ),
            SwitchListTile(
              title: const Text("Pengumuman"),
              subtitle: const Text("Saat ada pengumuman baru dari HR"),
              value: controller.announcements.value,
              onChanged: controller.allNotifications.value
                  ? (value) => controller.updateSetting('announcements', value)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}