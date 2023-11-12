import 'package:hyper_ui/shared/util/odoo_api/odoo_api.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class AuthService {
  static late OdooSession session;
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
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}
