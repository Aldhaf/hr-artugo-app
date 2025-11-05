import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var currentPageIndex = 0.obs;

  // Data untuk setiap halaman onboarding
  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboarding_1.png",
      "title": "Satu Aplikasi untuk Semua Kebutuhan Kerja Anda",
      "description":
          "Selamat datang di ArtuGo, Aplikasi Super Karyawan Anda. Dari absensi hingga pengajuan jadwal dan cuti, semua alat yang Anda butuhkan untuk produktivitas kini ada di satu tempat.",
    },
    {
      "image": "assets/images/onboarding_2.png",
      "title": "Absensi Akurat dengan Satu Ketukan",
      "description":
          "Lakukan check-in dan check-out dengan mudah. Sistem kami secara otomatis memvalidasi lokasi GPS dan jadwal Anda yang telah disetujui, memastikan setiap catatan absensi selalu akurat dan adil.",
    },
    {
      "image": "assets/images/onboarding_3.png",
      "title": "Rencanakan Jadwal Bulanan dalam Sekejap",
      "description":
          "Lupakan cara lama yang merepotkan. Cukup 'lukis' preferensi shift Anda langsung di kalender interaktif dan kirim sebagai satu pengajuan bulanan untuk persetujuan atasan.",
    },
    {
      "image": "assets/images/onboarding_4.png",
      "title": "Dasbor Cerdas & Notifikasi Instan",
      "description":
          "Pantau ringkasan jam kerja Anda langsung di dasbor dan dapatkan notifikasi real-time saat jadwal atau pengajuan cuti Anda disetujui. Jangan pernah ketinggalan informasi penting lagi.",
    },
  ];

  // Dipanggil saat halaman berganti
  void onPageChanged(int index) {
    currentPageIndex.value = index;
  }

  // Aksi tombol "Lanjut"
  void nextPage() {
    if (currentPageIndex.value == pages.length - 1) {
      completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  // Aksi tombol "Lewati"
  void skip() {
    completeOnboarding();
  }

  // Menyelesaikan onboarding dan navigasi
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Get.offAll(() => const LoginView()); // Arahkan ke halaman login
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
