import 'package:hyper_ui/shared/util/odoo_api/odoo_api.dart';

class AuthService {
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      await OdooApi.login(
        username: username,
        password: password,
      );
      return true;
    } on Exception {
      return false;
    }
  }
}
