// lib/module/login/controller/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/storage_service/storage_service.dart';
import '../../../service/firebase_service/firebase_service.dart';
import '../../../module/notification/controller/notification_controller.dart';
import '../../../service/work_profile_service/work_profile_service.dart';
import '../../../model/work_profile_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LoginController extends GetxController {
  final _storageService = StorageService();
  final _authService = Get.find<AuthService>();
  final _workProfileService = Get.find<WorkProfileService>();

  // --- State ---
  // 1. Best practice untuk form adalah menggunakan TextEditingController
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // State untuk visibilitas password
  var isPasswordObscured = true.obs;

  // 2. Tambahkan state reaktif untuk checkbox "Remember Me"
  var rememberMe = false.obs;

  // --- Lifecycle Methods ---
  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller di onInit
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _loadCredentials(); // Panggil method untuk memuat data
  }

  @override
  void onClose() {
    // Selalu dispose controller untuk mencegah memory leak
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // --- Methods ---
  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  // 3. Method baru untuk memuat kredensial
  void _loadCredentials() async {
    final credentials = await _storageService.getCredentials();
    if (credentials['email'] != null) {
      emailController.text = credentials['email']!;
      passwordController.text = credentials['password']!;
      rememberMe.value = true;
    }
  }

  // 4. Sesuaikan doLogin
  Future<void> doLogin() async {
    try {
      // 1. Lakukan Autentikasi terlebih dahulu
      var isSuccess = await _authService.login(
        login: emailController.text,
        password: passwordController.text,
      );

      if (!isSuccess) {
        Get.dialog(
          AlertDialog(
            title: const Text("Error"),
            content: const Text("Wrong username or password!"),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text("OK")),
            ],
          ),
        );
        return;
      }

      // 2. Handle logika "Remember Me"
      if (rememberMe.value) {
        await _storageService.saveCredentials(
            emailController.text, passwordController.text);
      } else {
        await _storageService.clearCredentials();
      }

      // Catat peristiwa login setelah berhasil
      FirebaseAnalytics.instance.logLogin(loginMethod: 'email');
      // Set User ID agar semua event berikutnya terhubung ke pengguna ini
      FirebaseAnalytics.instance
          .setUserId(id: _authService.currentSession?.userId.toString());

      print(
          "Login berhasil, menjalankan tugas-tugas post-login secara berurutan...");

      // 3. Ambil Employee ID
      await _workProfileService.fetchProfile();
      // 4. Inisialisasi Firebase Service
      await FirebaseService().initialize();
      // 5. Daftarkan service profil kerja
      await Get.putAsync(() => WorkProfileService().init());

      print("Semua tugas post-login selesai.");
      Get.find<NotificationController>().fetchNotifications();
      Get.offAllNamed('/dashboard');
    } catch (e) {
      print("Error selama proses login: $e");
      Get.snackbar("Error", "Terjadi kesalahan saat login: ${e.toString()}");
    }
  }
}
