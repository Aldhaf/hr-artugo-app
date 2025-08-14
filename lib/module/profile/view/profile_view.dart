// lib/module/profile/view/profile_view.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:shimmer/shimmer.dart';
import '../model/profile_model.dart';
import '/core/data_state.dart';
import '../controller/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      body: SafeArea(
        // <-- BUNGKUS DENGAN SAFEAREA

        // Gunakan Obx untuk memantau perubahan state
        child: Obx(() {
          final state = controller.profileState.value;

          // Tampilkan Shimmer saat loading
          if (state is DataLoading) {
            return const ProfileSkeleton();
          }

          // Tampilkan pesan error jika gagal
          if (state is DataError) {
            // LAKUKAN CASTING SECARA EKSPLISIT DI SINI
            // Ini akan 100% menyelesaikan error kompilasi
            final errorState = state as DataError;
            return Center(child: Text(errorState.message));
          }

          // Tampilkan konten jika sukses
          if (state is DataSuccess<Profile>) {
            final profile = state.data;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildProfileAvatar(profile),
                  const SizedBox(height: 16),
                  Text(
                    profile.userName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.jobTitle,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  _buildProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    label: "Notification Settings",
                    onTap: () => Get.toNamed('/notification_settings'),
                  ),
                  _buildProfileMenuItem(
                    icon: Icons.info_outline,
                    label: "About App",
                    onTap: () => Get.toNamed('/about_app'),
                  ),
                  const Divider(),
                  _buildProfileMenuItem(
                    icon: Icons.logout,
                    label: "Logout",
                    color: Colors.red,
                    onTap: () => controller.logout(),
                  ),
                ],
              ),
            );
          }
          return const SizedBox
              .shrink(); // Fallback jika state tidak terdefinisi
        }),
      ),
    );
  }

  // Helper widget untuk avatar inisial nama
  Widget _buildInitialAvatar(String name) {
    return CircleAvatar(
      radius: 60,
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
        style: const TextStyle(fontSize: 50),
      ),
    );
  }

  Widget _buildProfileAvatar(Profile profile) {
    // Cek jika imageUrl ada dan tidak kosong
    if (profile.imageUrl != null &&
        profile.imageUrl!.isNotEmpty &&
        profile.imageUrl!.length > 100) {
      try {
        final imageBytes = base64Decode(profile.imageUrl!);
        return CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(imageBytes),
        );
      } catch (e) {
        print("Gagal decode base64: $e");
        return _buildInitialAvatar(profile.userName);
      }
    }
    // Jika tidak ada imageUrl atau terlalu pendek, tampilkan avatar inisial
    return _buildInitialAvatar(profile.userName);
  }

  // Widget helper untuk setiap item menu
  // Helper widget untuk menu item
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Get.theme.primaryColor),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// WIDGET UNTUK SKELETON UI
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.white),
            const SizedBox(height: 12),
            Container(width: 200, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 150, height: 18, color: Colors.white),
            const SizedBox(height: 24),
            // Kerangka untuk menu
            Container(width: double.infinity, height: 50, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 50, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 50, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
