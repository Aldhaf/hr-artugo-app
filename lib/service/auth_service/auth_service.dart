import 'package:get/get.dart';
import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class AuthService {
  final _odooApi = Get.find<OdooApiService>();
  OdooSession? get currentSession => _odooApi.session;

  Future<bool> login({
    required String login,
    required String password,
  }) async {
    bool success = await _odooApi.login(
      login: login,
      password: password,
    );
    return success;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Coba ambil token dari penyimpanan lokal
    final token = prefs.getString('token');

    // Jika token tidak null dan tidak kosong, berarti pengguna sudah login.
    return token != null && token.isNotEmpty;
  }
}
