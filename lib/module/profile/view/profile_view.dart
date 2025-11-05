// lib/module/profile/view/profile_view.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:shimmer/shimmer.dart';
import '../model/profile_model.dart';
import '/core/data_state.dart';
import '../controller/profile_controller.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:hr_artugo_app/service/theme_service/theme_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    // final themeService = Get.find<ThemeService>();

    return Scaffold(
      // warna latar belakang utama sesuai desain baru
      body: SafeArea(
        top: false, // SafeArea diatur manual karena header tumpang tindih
        child: Obx(() {
          final state = controller.profileState.value;

          if (state is DataLoading) {
            // skeleton UI yang sudah diperbarui
            return const ProfileSkeletonNew();
          }

          if (state is DataError) {
            final errorState = state as DataError;
            return Center(
                child: Text(errorState.error ?? "Gagal memuat profil"));
          }

          if (state is DataSuccess<Profile>) {
            final profile = state.data;
            // Stack untuk menumpuk header dan konten
            return Stack(
              children: [
                // Lapisan 1: Latar belakang berwarna di bagian atas
                _buildHeaderBackground(context),

                // Lapisan 2: Konten utama yang bisa di-scroll
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    const SizedBox(height: 70), // Jarak agar avatar di tengah
                    _buildProfileAvatar(profile),
                    const SizedBox(height: 16),
                    Text(
                      profile.userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.jobTitle,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),

                    // Kartu Menu Grup 1
                    _buildMenuCard(
                      children: [
                        _buildProfileMenuItem(
                          icon: Icons.notifications_outlined,
                          label: "Notification Settings",
                          onTap: () => Get.toNamed('/notification_settings'),
                        ),
                        /*
                        Obx(() => SwitchListTile.adaptive(
                              // Tampilkan ikon sesuai tema saat ini
                              secondary: Icon(
                                themeService.isDarkMode.value
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: Get.theme.primaryColor,
                              ),
                              title: const Text(
                                "Mode Gelap",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: themeService.isDarkMode.value,
                              onChanged: (value) {
                                // Panggil fungsi untuk ganti tema
                                themeService.switchTheme();
                              },
                            )),
                        */
                        _buildProfileMenuItem(
                          icon: Icons.info_outline,
                          label: "About App",
                          onTap: () => Get.toNamed('/about_app'),
                        ),
                        _buildProfileMenuItem(
                          icon: Icons.gavel_outlined,
                          label: "Terms & Conditions",
                          onTap: () => Get.toNamed('/terms_and_conditions'),
                        ),
                        _buildProfileMenuItem(
                          icon: Icons.shield_outlined,
                          label: "Privacy Policy",
                          onTap: () => Get.toNamed('/privacy_policy'),
                          hideDivider: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Kartu Menu Grup 2
                    _buildMenuCard(
                      children: [
                        _buildProfileMenuItem(
                          icon: Icons.bug_report,
                          label: "Test Crashlytics",
                          color: Colors.orange,
                          onTap: () {
                            FirebaseCrashlytics.instance.crash();
                          },
                        ),
                        _buildProfileMenuItem(
                          icon: Icons.logout,
                          label: "Logout",
                          color: Colors.red,
                          onTap: () => controller.logout(),
                          hideDivider: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  // Widget Header Latar Belakang
  Widget _buildHeaderBackground(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
    );
  }

  // Widget Kartu untuk membungkus item menu
  Widget _buildMenuCard({required List<Widget> children}) {
    return Card(
      color: const Color(0xFFFFFFFF),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Helper widget untuk avatar
  Widget _buildProfileAvatar(Profile profile) {
    Widget avatarContent;
    if (profile.imageUrl != null &&
        profile.imageUrl!.isNotEmpty &&
        profile.imageUrl!.length > 100) {
      try {
        final imageBytes = base64Decode(profile.imageUrl!);
        avatarContent = CircleAvatar(
          radius: 50,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        avatarContent = _buildInitialAvatar(profile.userName);
      }
    } else {
      avatarContent = _buildInitialAvatar(profile.userName);
    }
    // border putih di sekeliling avatar
    return Center(
      child: CircleAvatar(
        radius: 54,
        backgroundColor: Colors.white,
        child: avatarContent,
      ),
    );
  }

  Widget _buildInitialAvatar(String name) {
    return CircleAvatar(
      radius: 50,
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
        style: const TextStyle(fontSize: 50),
      ),
    );
  }

  // Helper widget untuk item menu
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool hideDivider = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color ?? Get.theme.primaryColor),
          title: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey.shade100,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
          onTap: onTap,
        ),
        if (!hideDivider)
          Padding(
            padding: const EdgeInsets.only(left: 70.0), // Divider tidak full
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
      ],
    );
  }
}

// Widget Skeleton UI yang disesuaikan dengan desain baru
class ProfileSkeletonNew extends StatelessWidget {
  const ProfileSkeletonNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Latar belakang header skeleton
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        // Konten shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 70),
              const Center(
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 200,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 150,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Kerangka untuk kartu menu
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
