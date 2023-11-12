import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';
import 'package:hyper_ui/service/auth_service/auth_service.dart';

class LoginController extends State<LoginView> {
  static late LoginController instance;
  late LoginView view;

  @override
  void initState() {
    instance = this;
    super.initState();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => widget.build(context, this);

  String username = "admin";
  String password = "joko@123";
  doLogin() async {
    var isSuccess = await AuthService().login(
      username: username,
      password: password,
    );

    print("username: $username");
    print("password: $password");
    print("isSuccess: $isSuccess");

    if (!isSuccess) {
      showInfoDialog("Wrong username or password!");
      return;
    }

    Get.offAll(MainNavigationView());
  }
}
