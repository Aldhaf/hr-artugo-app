import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService extends GetxService {
  static const _keyDashboardCache = 'dashboard_cache';

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    // Ubah map menjadi string JSON sebelum disimpan
    await prefs.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      // Ubah string JSON kembali menjadi map
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Menyimpan data mentah (dalam format Map/JSON) ke cache
  Future<void> saveDashboardCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    // Ubah Map menjadi String JSON untuk disimpan
    await prefs.setString(_keyDashboardCache, jsonEncode(data));
  }

  /// Mengambil data dari cache dan mengembalikannya sebagai Map
  Future<Map<String, dynamic>?> getDashboardCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDashboardCache);
    if (jsonString != null) {
      // Ubah String JSON kembali menjadi Map
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }
  
  /// Menghapus semua cache yang dikelola oleh service ini.
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDashboardCache);
    // Tambahkan prefs.remove() lain jika ada cache lain
  }
}