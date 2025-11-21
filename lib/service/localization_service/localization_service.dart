import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LocalizationService extends GetxService {
  static const _storageKey = 'language_code';
  
  // Daftar bahasa yang didukung
  static final locales = [
    const Locale('en', 'US'),
    const Locale('id', 'ID'),
  ];

  // Fungsi inisialisasi (dipanggil di main.dart)
  Future<LocalizationService> init() async {
    return this;
  }

  // Mendapatkan locale saat ini dari storage atau device
  Locale get currentLocale {
    final prefs = Get.find<SharedPreferences>(); // Asumsi SharedPreferences sudah di-put di main
    final String? languageCode = prefs.getString(_storageKey);
    
    if (languageCode == 'id') return const Locale('id', 'ID');
    if (languageCode == 'en') return const Locale('en', 'US');
    
    // Default ke bahasa perangkat jika belum pernah diset
    return Get.deviceLocale ?? const Locale('id', 'ID');
  }

  // Fungsi untuk mengganti bahasa
  void changeLocale(String languageCode) async {
    final locale = _getLocaleFromLanguage(languageCode);
    await Get.updateLocale(locale);
    
    // Simpan ke storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, languageCode);
  }

  Locale _getLocaleFromLanguage(String langCode) {
    if (langCode == 'en') return const Locale('en', 'US');
    return const Locale('id', 'ID'); // Default ID
  }
}