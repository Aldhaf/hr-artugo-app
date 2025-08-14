// lib/module/main_navigation/view/main_navigation_view.dart

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get;

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());
    final List<Widget> pages = [
      DashboardView(),
      const AttendanceHistoryListView(),
      const TimeOffHistoryListView(),
      ProfileView(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Jika tidak sedang di tab Dashboard, kembali ke Dashboard
        if (controller.selectedIndex.value != 0) {
          controller.onTabTapped(0);
          return false; // Mencegah aplikasi keluar
        }

        // Jika sudah di tab Dashboard, tampilkan dialog konfirmasi
        bool exit = await Get.dialog(
          AlertDialog(
            title: const Text('Konfirmasi'),
            content:
                const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Get.back(result: false), // Tutup dialog, jangan keluar
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () =>
                    Get.back(result: true), // Tutup dialog, izinkan keluar
                child: const Text('Ya'),
              ),
            ],
          ),
        );

        // Kembalikan hasil dari dialog. Jika dialog ditutup (misal: menekan di luar),
        // anggap sebagai 'false' agar tidak keluar.
        return exit ?? false;
      },
      child: Scaffold(
        body: PageView(
          controller: controller.pageController,
          onPageChanged: (index) {
            controller.selectedIndex.value = index;
          },
          children: pages,
        ),
        bottomNavigationBar: Obx(() => Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: GNav(
                  gap: 4,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  tabBackgroundColor: Theme.of(context).primaryColor,
                  color: Colors.black54,
                  textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                  tabs: const [
                    GButton(icon: Icons.dashboard, text: 'Dashboard'),
                    GButton(icon: Icons.calendar_month, text: 'Attendance'),
                    GButton(icon: Icons.access_time_filled, text: 'Time Off'),
                    GButton(icon: Icons.person, text: 'User'),
                  ],
                  selectedIndex: controller.selectedIndex.value,
                  onTabChange: (index) => controller.onTabTapped(index),
                ),
              ),
            )),
      ),
    );
  }
}
