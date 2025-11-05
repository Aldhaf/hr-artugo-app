import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/storage_service/storage_service.dart';
import '../../../service/firebase_service/firebase_service.dart';
import '../../../service/connectivity_service/connectivity_service.dart';
import '../../../module/notification/controller/notification_controller.dart';
import '../../../service/work_profile_service/work_profile_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LoginController extends GetxController {
  final _storageService = StorageService();
  final _authService = Get.find<AuthService>();
  final _workProfileService = Get.find<WorkProfileService>();
  final _connectivityService = Get.find<ConnectivityService>();

  // --- State ---
  // Best practice untuk form adalah menggunakan TextEditingController
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // State untuk visibilitas password
  var isPasswordObscured = true.obs;

  // Menambahkan state reaktif untuk checkbox "Remember Me"
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

  // Method baru untuk memuat kredensial
  void _loadCredentials() async {
    final credentials = await _storageService.getCredentials();
    if (credentials['email'] != null) {
      emailController.text = credentials['email']!;
      passwordController.text = credentials['password']!;
      rememberMe.value = true;
    }
  }

  Future<void> doLogin() async {
    // Cek konektivitas
    if (!_connectivityService.isOnline.value) {
      Get.snackbar("Offline",
          "Tidak ada koneksi internet. Silakan periksa jaringan Anda.");
      return; // Hentikan proses jika offline
    }

    try {
      // Melanjutkan proses autentikasi jika online
      var isSuccess = await _authService.login(
        login: emailController.text,
        password: passwordController.text,
      );

      if (!isSuccess) {
        // Pesan error jika autentikasi gagal dari server
        Get.dialog(
          AlertDialog(
            title: const Text("Gagal Login"), // Judul lebih jelas
            content: const Text(
                "Email atau password yang Anda masukkan salah."), // Pesan lebih jelas
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text("OK")),
            ],
          ),
        );
        return;
      }

      // Handle logika "Remember Me"
      if (rememberMe.value) {
        await _storageService.saveCredentials(
            emailController.text, passwordController.text);
      } else {
        await _storageService.clearCredentials();
      }

      // Mencatat peristiwa login setelah berhasil
      FirebaseAnalytics.instance.logLogin(loginMethod: 'email');
      FirebaseAnalytics.instance
          .setUserId(id: _authService.currentSession?.userId.toString());

      // Inisialisasi Firebase Service
      await FirebaseService().initialize();

      // Ambil profil kerja (termasuk employee ID)
      await _workProfileService.fetchProfile();

      // Ambil notifikasi awal
      Get.find<NotificationController>().fetchNotifications();

      // Navigasi ke dashboard
      Get.offAllNamed('/dashboard');
    } catch (e) {
      // Menangani error koneksi atau server lainnya
      print("Login error: $e"); // Log error untuk debugging
      String errorMessage = "Terjadi kesalahan saat mencoba login.";
      if (e is Exception &&
          e.toString().contains("Tidak bisa terhubung ke server")) {
        errorMessage = "Gagal terhubung ke server. Silakan coba lagi nanti.";
      }
      // Tambahkan penanganan error spesifik lainnya jika perlu

      Get.snackbar("Error", errorMessage);
    }
  }
}
