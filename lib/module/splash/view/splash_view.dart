import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:hr_artugo_app/service/auth_service/auth_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Jeda agar animasi sempat terlihat
    await Future.delayed(const Duration(seconds: 3));
    
    final authService = Get.find<AuthService>();

    bool isLoggedIn = await authService.isLoggedIn();

    if (isLoggedIn) {
      Get.offAllNamed('/dashboard');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Pastikan Anda sudah punya file animasi lottie di path ini
        child: Lottie.asset('assets/animations/loading.json'),
      ),
    );
  }
}
