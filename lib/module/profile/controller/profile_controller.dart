import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../core/data_state.dart';
import '../../../service/cache_service/cache_service.dart';
import '../../../service/storage_service/storage_service.dart';
import '../model/profile_model.dart';
// Import yang kita butuhkan
import '../../../service/work_profile_service/work_profile_service.dart'; 

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
    getProfileFromService();
  }

  void getProfileFromService() {
    profileState.value = const DataLoading();
    // Ambil data dari service terpusat
    final profile = Get.find<WorkProfileService>().workProfile;

    print("[DEBUG-PROFILE] Mengambil profil dari service. Jabatan: ${profile?.jobTitle}");

    if (profile != null) {
      final uiProfile = Profile(
        userName: profile.employeeName,
        jobTitle: profile.jobTitle ?? 'No Job Title',
        imageUrl: OdooApi.session != null ? OdooApi.getUserImageUrl(OdooApi.session!.userId) : null,
      );
      profileState.value = DataSuccess(uiProfile);
    } else {
      profileState.value = const DataError("Gagal memuat profil. Silakan coba login ulang.");
    }
  }

  // FUNGSI LOGOUT YANG SUDAH DIPERBAIKI DAN BENAR
  Future<void> logout() async {
    Get.find<WorkProfileService>().clearProfile();

    // 1. Bersihkan cache dan kredensial (Langkah ini sudah benar)
    await _cacheService.clearAllCache();
    await _storageService.clearCredentials();
    Get.offAll(() => const LoginView());
  }
}
