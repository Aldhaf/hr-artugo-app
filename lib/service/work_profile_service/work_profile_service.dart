import 'package:get/get.dart';
import 'package:hr_artugo_app/model/work_profile_model.dart';
import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';
import 'package:hr_artugo_app/service/cache_service/cache_service.dart';

class WorkProfileService extends GetxService {
  final _cacheService = CacheService();
  static const _cacheKey = 'work_profile';
  final _odooApi = Get.find<OdooApiService>();

  // 2. Deklarasikan variabel reaktif untuk menampung profil
  final Rxn<WorkProfile> _workProfile = Rxn<WorkProfile>();

  // Buat getter publik agar controller lain bisa mengakses nilainya
  WorkProfile? get workProfile => _workProfile.value;

  Future<WorkProfileService> init() async {
    // Panggil fungsi fetchProfile yang sudah ada untuk memuat data awal
    await fetchProfile();
    // Kembalikan 'this' (instance dari service ini) sesuai yang diharapkan oleh Get.putAsync
    return this;
  }

  Future<WorkProfile?> fetchProfile() async {
    try {
      final profileData = await _odooApi.getWorkProfile();
      final Map<String, dynamic> data = await _odooApi.getWorkProfile();
      
      print("[DEBUG-SERVICE] Raw data dari OdooApi: $data");  // Debug log

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
      print("Error fetching work profile: $e");
      clearProfile();
      return null;
    }
  }

  void setProfile(WorkProfile profile) {
    print("Profil kerja disimpan ke service.");
    _workProfile.value = profile;
  }

  void clearProfile() {
    _workProfile.value = null;
    _cacheService.clearAllCache();
    print("Profil kerja telah dibersihkan.");
  }
}
