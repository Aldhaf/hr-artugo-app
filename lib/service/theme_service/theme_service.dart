// lib/service/theme_service/theme_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  late SharedPreferences _prefs;
  final _themeKey = 'isDarkMode'; // Key untuk menyimpan di SharedPreferences

  // Menggunakan .obs agar state-nya reaktif
  var isDarkMode = false.obs;

  // Fungsi inisialisasi untuk memuat tema saat aplikasi dimulai
  Future<ThemeService> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Muat preferensi tema yang tersimpan
    // Jika tidak ada, default-nya 'false' (light mode)
    isDarkMode.value = _prefs.getBool(_themeKey) ?? false;
    return this;
  }

  // Getter untuk mendapatkan ThemeMode saat ini
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Fungsi untuk mengganti tema
  void switchTheme() {
    // 1. Ubah state reaktif
    isDarkMode.value = !isDarkMode.value;
    
    // 2. Terapkan perubahan tema ke GetX
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    // 3. Simpan pilihan baru ke SharedPreferences
    _prefs.setBool(_themeKey, isDarkMode.value);
  }
}