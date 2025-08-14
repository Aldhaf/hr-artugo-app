import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/notification/model/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controller/notification_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  // Anda bisa memindahkan 'controller' ke sini agar tidak dideklarasikan dua kali
  final controller = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi"),
      ),
      body: RefreshIndicator(
        // Pull-to-refresh sekarang akan memanggil markAllAsRead juga
        onRefresh: () => controller.markAllAsRead(),
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.notificationList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notificationList.isEmpty) {
            return const Center(
                child: Text("Tidak ada notifikasi",
                    style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: controller.notificationList.length,
            itemBuilder: (context, index) {
              final notification = controller.notificationList[index];

              // --- PERUBAHAN UTAMA: BUNGKUS NotificationTile DENGAN Dismissible ---
              return Dismissible(
                // Key wajib ada dan harus unik untuk setiap item
                key: ValueKey(notification.id),

                // Arah geser (dari kanan ke kiri)
                direction: DismissDirection.endToStart,

                // Callback yang dijalankan setelah item digeser penuh
                onDismissed: (direction) {
                  // Panggil fungsi delete di controller
                  controller.deleteNotification(notification.id);

                  // Tampilkan snackbar konfirmasi (opsional)
                  Get.snackbar(
                    "Dihapus",
                    "'${notification.title}' telah dihapus.",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                },

                // Tampilan background yang muncul saat digeser
                background: Container(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.white),
                        const SizedBox(width: 8.0),
                        const Text("Hapus",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.9, end: 0.0),

                // Widget utama Anda (NotificationTile)
                child: NotificationTile(notification: notification),
              );
            },
          );
        }),
      ),
    );
  }
}

// WIDGET NotificationTile ANDA (TIDAK ADA PERUBAHAN)
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (notification.type == NotificationType.leaveApproval &&
            notification.relatedId != null) {
          Get.toNamed('/time_off_detail', arguments: notification.relatedId);
        }
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        notification.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          notification.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54, fontSize: 13.0),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeago.format(notification.receivedAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (!notification.isRead) const SizedBox(height: 5),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
            ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
