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
        title: Text('settings_notif_title'.tr),
      ),
      body: Obx(
        () => ListView(
          children: [
            SwitchListTile(
              title: Text('settings_notif_all'.tr),
              subtitle: Text('settings_notif_all_desc'.tr),
              value: controller.allNotifications.value,
              onChanged: (value) =>
                  controller.updateSetting('allNotifications', value),
            ),
            const Divider(),
            SwitchListTile(
              title: Text('settings_notif_attendance'.tr),
              subtitle: Text('settings_notif_attendance_desc'.tr),
              value: controller.attendanceReminders.value,
              onChanged: controller.allNotifications.value
                  ? (value) =>
                      controller.updateSetting('attendanceReminders', value)
                  : null,
            ),
            SwitchListTile(
              title: Text('settings_notif_leave'.tr),
              subtitle: Text('settings_notif_leave_desc'.tr),
              value: controller.leaveApprovals.value,
              onChanged: controller.allNotifications.value
                  ? (value) => controller.updateSetting('leaveApprovals', value)
                  : null,
            ),
            SwitchListTile(
              title: Text('settings_notif_announcement'.tr),
              subtitle: Text('settings_notif_announcement_desc'.tr),
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
