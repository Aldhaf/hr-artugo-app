// lib/module/main_navigation/controller/main_navigation_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  // Variabel untuk menyimpan index tab yang aktif, dibuat reaktif.
  var selectedIndex = 0.obs;

  //Tambah PageController
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi PageController saat controller dibuat
    pageController = PageController();
  }

  @override
  void onClose() {
    // Hancurkan PageController saat controller ditutup untuk mencegah memory leak
    pageController.dispose();
    super.onClose();
  }

  // Fungsi ini akan dipanggil saat tab di navigation bar ditekan
  void onTabTapped(int index) {
    selectedIndex.value = index;
    // Perintahkan PageView untuk pindah halaman tanpa animasi
    pageController.jumpToPage(index);
  }
}
