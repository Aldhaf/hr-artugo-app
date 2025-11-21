import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:hr_artugo_app/module/my_schedule/view/my_schedule_view.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavigationController());
    final List<Widget> pages = [
      DashboardView(),
      const AttendanceHistoryListView(),
      // const TimeOffHistoryListView(),  // nonaktif sementara
      const MyScheduleView(),
      ProfileView(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedIndex.value != 0) {
          controller.onTabTapped(0);
          return false;
        }

        bool exit = await Get.dialog(
          AlertDialog(
            title: Text('confirm'.tr),
            content: Text('confirm_state'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('no'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('yes'.tr),
              ),
            ],
          ),
        );

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
                  tabs: [
                    GButton(icon: Icons.dashboard, text: 'nav_dashboard'.tr),
                    GButton(
                        icon: Icons.calendar_month, text: 'nav_attendance'.tr),
                    // GButton(icon: Icons.access_time_filled, text: 'Time Off'), // nonaktif sementara
                    GButton(
                        icon: Icons.edit_calendar_outlined,
                        text: 'nav_schedule'.tr),
                    GButton(icon: Icons.person, text: 'nav_profile'.tr),
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
