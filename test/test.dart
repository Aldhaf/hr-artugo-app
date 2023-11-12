import 'package:hyper_ui/core.dart';

void main() async {
  await AuthService().login(username: "admin", password: "joko@123");
  var response = await TimeOffService().get();
  print(response);
}
