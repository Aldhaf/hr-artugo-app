import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../controller/dashboard_controller.dart'; // Pastikan controller dashboard diimpor
import '../widget/info_card.dart';
import '../widget/summary_card.dart';
import '../widget/clock_widget.dart';
import '../widget/animated_checkin_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hr_artugo_app/core/data_state.dart';
import 'package:hr_artugo_app/module/notification/controller/notification_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardC = Get.put(DashboardController());
    final notificationC = Get.find<NotificationController>();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
        // Kita tidak lagi menggunakan Stack, tapi Column biasa
        // dengan background AppBar yang diwarnai.
        // Di dalam DashboardView
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Obx(() {
            // Pantau locationState, bukan location.value lagi
            final state = dashboardC.locationState.value;

            // Tampilkan UI berdasarkan state-nya
            if (state is DataSuccess<String>) {
              // Jika sukses, tampilkan alamat
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Location",
                      style: TextStyle(color: Colors.white70, fontSize: 12.0)),
                  Text(
                    state.data,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              );
            }

            if (state is DataError<String>) {
              // Jika error, tampilkan pesan error dan tombol refresh
              return Row(
                children: [
                  Expanded(
                    child: Text(state.message,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14.0)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => dashboardC.refreshLocation(),
                  )
                ],
              );
            }

            // Default: Tampilkan saat loading
            return const Text("Mencari lokasi...",
                style: TextStyle(color: Colors.white70, fontSize: 14.0));
          }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                // Arahkan ke halaman notifikasi saat ditekan
                onPressed: () => Get.toNamed('/notifications'),

                // Bungkus Badge dengan Obx untuk membuatnya reaktif
                icon: Obx(() => Badge(
                      // Tampilkan badge hanya jika ada notifikasi belum dibaca
                      isLabelVisible: notificationC.unreadCount.value > 0,
                      label: Text(
                        // Ambil jumlah notifikasi dari controller
                        "${notificationC.unreadCount.value}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                    )),
              ),
            ),
          ],
        ),
        body: Obx(() {
          // Jika sedang loading, tampilkan spinner
          if (dashboardC.isLoading.value) {
            // Ganti spinner dengan Shimmer
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: const DashboardSkeleton(), // Panggil widget kerangka
            );
          }

          return RefreshIndicator(
              onRefresh: () => dashboardC.refreshData(),
              child: Container(
                  color: const Color(0xfff5f5f5),
                  child: Column(
                    children: [
                      // --- BAGIAN HEADER BIRU ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // <-- Hapus 'const' dari sini
                            Obx(() => Text(
                                  // Gunakan Obx untuk teks yang dinamis
                                  "Welcome, ${dashboardC.userName.value}",
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )),
                            const SizedBox(height: 8),
                            const ClockWidget(),
                          ],
                        ),
                      ),

                      // --- KONTEN UTAMA ---
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- KARTU CHECK IN, CHECK OUT, DAN WORKING HOURS ---
                              // Dibuat seragam menggunakan InfoCard
                              Obx(() => Row(
                                    children: [
                                      Expanded(
                                        child: InfoCard(
                                          title: "Check In",
                                          time: dashboardC.checkInTime.value,
                                          icon: Icons.login,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InfoCard(
                                          title: "Check Out",
                                          time: dashboardC.checkOutTime.value,
                                          icon: Icons.logout,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InfoCard(
                                          title: "Duration",
                                          time: dashboardC.workingHours.value,
                                          icon: Icons.timer_outlined,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  )),
                              const SizedBox(height: 24.0),

                              // --- RINGKASAN BULANAN ---
                              const Text(
                                "Attendance for this Month",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12.0),
                              Obx(() => Row(
                                    children: [
                                      Expanded(
                                          child: SummaryCard(
                                              title: "Present",
                                              value:
                                                  "${dashboardC.presentDays.value}",
                                              color: Colors.green.shade100,
                                              textColor:
                                                  Colors.green.shade800)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: SummaryCard(
                                              title: "Absents",
                                              value:
                                                  "${dashboardC.absentDays.value}",
                                              color: Colors.red.shade100,
                                              textColor: Colors.red.shade800)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: SummaryCard(
                                              title: "Late In",
                                              value:
                                                  "${dashboardC.lateInDays.value}",
                                              color: Colors.orange.shade100,
                                              textColor:
                                                  Colors.orange.shade800)),
                                    ],
                                  )),
                              const SizedBox(height: 24.0),

                              SizedBox(
                                width: double.infinity,
                                child: Obx(() {
                                  // Gunakan state boolean yang lebih bersih
                                  bool hasCheckedOut =
                                      dashboardC.checkOutTime.value != "N/A";

                                  if (hasCheckedOut) {
                                    return Card(
                                      elevation: 0,
                                      color: Colors.grey[200],
                                      child: const ListTile(
                                        leading: Icon(Icons.check_circle,
                                            color: Colors.green),
                                        title: Text("Absensi hari ini selesai"),
                                      ),
                                    );
                                  }

                                  // Gunakan hasCheckedInToday dari controller
                                  if (dashboardC.hasCheckedInToday.value) {
                                    // --- GANTI TOMBOL CHECK OUT DENGAN INI ---
                                    return AnimatedCheckinButton(
                                      title: "Check Out",
                                      icon: Icons.logout,
                                      color: Colors.red.shade400,
                                      onPressed: () => dashboardC
                                          .doCheckOut(), // Pastikan doCheckOut juga diubah seperti doCheckIn
                                    );
                                  }

                                  // --- GANTI TOMBOL CHECK IN DENGAN INI ---
                                  return AnimatedCheckinButton(
                                    title: "Check In",
                                    icon: Icons.login,
                                    color:
                                        primaryColor, // atau Theme.of(context).primaryColor
                                    onPressed: () => dashboardC.doCheckIn(),
                                  );
                                }),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )));
        }));
  }
}

// BUAT WIDGET BARU UNTUK TAMPILAN SKELETON
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Tiru tata letak asli Anda dengan Container abu-abu
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics:
          const NeverScrollableScrollPhysics(), // Non-aktifkan scroll saat loading
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kerangka untuk Info Cards
          Row(
            children: List.generate(
                3,
                (index) => Expanded(
                      child: Card(
                        elevation: 0,
                        child: Container(height: 80, color: Colors.white),
                      ),
                    )).expand((w) => [w, const SizedBox(width: 12)]).toList()
              ..removeLast(),
          ),
          const SizedBox(height: 24),
          // Kerangka untuk Judul
          Container(width: 200, height: 20, color: Colors.white),
          const SizedBox(height: 12),
          // Kerangka untuk Summary Cards
          Row(
            children: List.generate(
                3,
                (index) => Expanded(
                      child: Card(
                        elevation: 0,
                        child: Container(height: 80, color: Colors.white),
                      ),
                    )).expand((w) => [w, const SizedBox(width: 12)]).toList()
              ..removeLast(),
          ),
          const SizedBox(height: 24),
          // Kerangka untuk Tombol Swipe
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
    );
  }
}
