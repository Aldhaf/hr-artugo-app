import 'package:hyper_ui/core.dart';
import 'package:hyper_ui/service/time_off_service/time_off_service.dart';

void main() async {
  await AuthService().login(username: "admin", password: "joko@123");
  var response = await TimeOffService().get();
  print(response);
}
