import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService extends GetxService {
  static const _keyDashboardCache = 'dashboard_cache';

  /*
  Menyimpan sebuah Map<String, dynamic> ke SharedPreferences.
  Data Map akan dikonversi menjadi string JSON sebelum disimpan.
  Menggunakan [key] dinamis yang diberikan sebagai parameter.
  */
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah map menjadi string JSON sebelum disimpan
    await prefs.setString(key, jsonEncode(value));
  }

  /*
  Mengambil data dari SharedPreferences berdasarkan [key] yang diberikan.
  Data yang tersimpan (string JSON) akan dikonversi kembali menjadi Map<String, dynamic>.
  Mengembalikan null jika key tidak ditemukan.
  */
  Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      // Mengubah string JSON kembali menjadi map
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /*
  Menyimpan data spesifik untuk cache dashboard ke SharedPreferences.
  Data Map [data] akan dikonversi menjadi string JSON.
  Menggunakan kunci internal [_keyDashboardCache].
  */
  Future<void> saveDashboardCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    // Ubah Map menjadi String JSON untuk disimpan
    await prefs.setString(_keyDashboardCache, jsonEncode(data));
  }

  /*
  Mengambil data cache dashboard dari SharedPreferences.
  Data string JSON yang tersimpan akan dikonversi kembali menjadi Map<String, dynamic>.
  Menggunakan kunci internal [_keyDashboardCache].
  Mengembalikan null jika cache dashboard tidak ditemukan.
  */
  Future<Map<String, dynamic>?> getDashboardCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDashboardCache);
    if (jsonString != null) {
      // Mengubah String JSON kembali menjadi Map
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }
  
  /*
  Menghapus data cache dashboard ([_keyDashboardCache]) dari SharedPreferences.
  Catatan: Fungsi ini saat ini hanya menghapus cache dashboard, bukan semua cache.
  */
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDashboardCache);
  }
}