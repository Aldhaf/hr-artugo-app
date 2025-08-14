import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
// Impor yang diperlukan
import '../../../core/data_state.dart';
import '../../../service/cache_service/cache_service.dart';
import '../../../service/storage_service/storage_service.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  // Gunakan satu state untuk mengelola semua kondisi (loading, success, error)
  var profileState = Rx<DataState<Profile>>(const DataLoading());

  // Instance service untuk logout
  final _cacheService = CacheService();
  final _storageService = StorageService();
  final String _cacheKey = "profile_data";

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    // 1. Coba muat data dari cache terlebih dahulu untuk ditampilkan seketika
    final cachedData = await _cacheService.getMap(_cacheKey);
    if (cachedData != null) {
      profileState.value = DataSuccess(Profile.fromJson(cachedData));
      print("Data profil dimuat dari cache.");
    } else {
      profileState.value = const DataLoading();
    }

    // 2. Selalu ambil data terbaru dari server di latar belakang
    try {
      final session = OdooApi.session;
      if (session == null) {
        profileState.value = const DataError("Sesi tidak ditemukan.");
        return;
      }

      final userName = session.userName;
      String jobTitle = "No Job Title";
      String? imageBase64; // Variabel untuk menyimpan data gambar base64

      if (OdooApi.employeeId != null) {
        var employeeData = await OdooApi.get(
          model: "hr.employee",
          where: [
            ['id', '=', OdooApi.employeeId]
          ],
          fields: ["job_title", "image_1920"],
          limit: 1,
        );

        if (employeeData.isNotEmpty) {
          final employee = employeeData.first;
          if (employee['job_title'] is String) {
            jobTitle = employee['job_title'];
          }
          if (employee['image_1920'] is String) {
            imageBase64 = employee['image_1920'];
          }
        }
      }

      final freshProfile = Profile(
        userName: userName,
        jobTitle: jobTitle,
        imageUrl: imageBase64,
      );

      // 3. Perbarui UI dengan data terbaru dan simpan ke cache
      profileState.value = DataSuccess(freshProfile);
      await _cacheService.saveMap(_cacheKey, freshProfile.toJson());
      print("Data profil diperbarui dari server dan disimpan ke cache.");
    } catch (e) {
      // Jika server gagal DAN tidak ada cache, tampilkan error
      if (cachedData == null) {
        profileState.value = DataError("Gagal memuat data profil: $e");
      }
    }
  }

  // FUNGSI LOGOUT YANG SUDAH DIPERBAIKI DAN BENAR
  Future<void> logout() async {
    // 1. Bersihkan cache dan kredensial (Langkah ini sudah benar)
    await _cacheService.clearAllCache();
    await _storageService.clearCredentials();
    Get.offAll(() => const LoginView());
  }
}
