import 'package:get/get.dart';
import 'package:hr_artugo_app/model/work_profile_model.dart';
import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';
import 'package:hr_artugo_app/service/cache_service/cache_service.dart';

class WorkProfileService extends GetxService {
  final _cacheService = CacheService();
  final _odooApi = Get.find<OdooApiService>();

  // Deklarasi variabel reaktif untuk menampung profil
  final Rxn<WorkProfile> _workProfile = Rxn<WorkProfile>();

  // Membuat getter publik agar controller lain bisa mengakses nilainya
  WorkProfile? get workProfile => _workProfile.value;

  Future<WorkProfileService> init() async {
    // Memanggil fungsi fetchProfile yang sudah ada untuk memuat data awal
    await fetchProfile();
    // Kembalikan 'this' (instance dari service ini) sesuai oleh Get.putAsync
    return this;
  }

  Future<WorkProfile?> fetchProfile() async {
    try {
      final profileData = await _odooApi.getWorkProfile();
      final Map<String, dynamic> data = await _odooApi.getWorkProfile();

      if (data.isNotEmpty && data['error'] == null) {

        // --- LOGIKA IMAGE URL ---
        if (_odooApi.session != null) {
          profileData['imageUrl'] = _odooApi.getUserImageUrl(_odooApi.session!.userId);
        }

        final newProfile = WorkProfile.fromJson(profileData);
        
        // Simpan profil baru ke dalam variabel reaktif
        _workProfile.value = newProfile;
        return newProfile;
      } else {
        clearProfile();
        return null;
      }
    } catch (e) {
      clearProfile();
      return null;
    }
  }

  void setProfile(WorkProfile profile) {
    _workProfile.value = profile;
  }

  void clearProfile() {
    _workProfile.value = null;
    _cacheService.clearAllCache();
  }
}
