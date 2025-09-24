import 'package:get/get.dart';
import 'package:hr_artugo_app/model/work_profile_model.dart'; 
import 'package:hr_artugo_app/service/cache_service/cache_service.dart';

class WorkProfileService extends GetxService {
  final _cacheService = CacheService();
  static const _cacheKey = 'work_profile';

  WorkProfile? workProfile;

  Future<WorkProfileService> init() async {
    // Saat service diinisialisasi, coba muat dari cache
    final cachedData = await _cacheService.getMap(_cacheKey);
    if (cachedData != null) {
      workProfile = WorkProfile.fromJson(cachedData);
      print("Profil kerja dimuat dari cache.");
    }
    return this;
  }

  void setProfile(WorkProfile profile) {
    workProfile = profile;
    // Simpan juga ke cache setiap kali ada data baru
    _cacheService.saveMap(_cacheKey, profile.toJson());
    print("Profil kerja disimpan ke service dan cache.");
  }
  
  void clearProfile() {
    workProfile = null;
    _cacheService.clearAllCache();
    print("Profil kerja dan semua cache telah dibersihkan.");
  }
}