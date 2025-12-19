import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:hr_artugo_app/service/auth_service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final authService = Get.find<AuthService>();
    bool isLoggedIn = await authService.isLoggedIn();

    if (isLoggedIn) {
      Get.offAllNamed('/dashboard');
    } else {
      final prefs = await SharedPreferences.getInstance();
      final bool onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;
      if (!onboardingCompleted) {
        Get.offAllNamed('/onboarding');
      } else {
        Get.offAllNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pastikan sama dengan warna native splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan Logo (Gunakan file yang sama agar konsisten)
            Image.asset(
              'assets/icon/splash_icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),

            // Animasi Loading Lottie
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset('assets/animations/loading.json'),
            ),
          ],
        ),
      ),
    );
  }
}
