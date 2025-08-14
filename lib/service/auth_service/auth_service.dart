import 'package:hyper_ui/shared/util/odoo_api/odoo_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Properti session tidak lagi dibutuhkan di sini, karena sudah dikelola oleh OdooApi
  // static late OdooSession session;

  Future<bool> login({
    required String login,
    required String password,
  }) async {
    // Panggil OdooApi.login dan langsung kembalikan hasilnya.
    // Jika OdooApi.login mengembalikan true, fungsi ini juga mengembalikan true.
    // Jika OdooApi.login mengembalikan false (karena error), fungsi ini juga akan mengembalikan false.
    bool success = await OdooApi.login(
      login: login,
      password: password,
    );
    return success;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Coba ambil token dari penyimpanan lokal
    final token = prefs.getString('token');

    // Jika token tidak null dan tidak kosong, berarti pengguna sudah login.
    return token != null && token.isNotEmpty;
  }
}
