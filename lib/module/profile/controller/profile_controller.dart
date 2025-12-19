import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../core/data_state.dart';
import '../../../service/cache_service/cache_service.dart';
import '../../../service/storage_service/storage_service.dart';
import '../model/profile_model.dart';
import '../../../service/work_profile_service/work_profile_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ProfileController extends GetxController {
  // Menggunakan satu state untuk mengelola semua kondisi (loading, success, error)
  var profileState = Rx<DataState<Profile>>(const DataLoading());

  // Instance service untuk logout
  final _cacheService = CacheService();
  final _storageService = StorageService();

  @override
  void onInit() {
    super.onInit();
    getProfileFromService();
  }

  void getProfileFromService() {
    profileState.value = const DataLoading();
    // Mengambil data dari WorkProfileService
    final profile = Get.find<WorkProfileService>().workProfile;

    

    if (profile != null) {
      final uiProfile = Profile(
        userName: profile.employeeName,
        jobTitle: profile.jobTitle ?? 'No Job Title',
        imageUrl: profile.imageUrl,
      );
      profileState.value = DataSuccess(uiProfile);
    } else {
      profileState.value =
          const DataError("Gagal memuat profil. Silakan coba login ulang.");
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    FirebaseAnalytics.instance.logEvent(name: 'logout');
    // Hapus User ID saat logout
    FirebaseAnalytics.instance.setUserId(id: null);

    Get.find<WorkProfileService>().clearProfile();

    // Membersihkan cache dan kredensial
    await _cacheService.clearAllCache();
    await _storageService.clearCredentials();
    Get.offAll(() => const LoginView());
  }
}
