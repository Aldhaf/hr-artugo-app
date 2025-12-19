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
      Get.snackbar("Offline", "Tidak ada koneksi internet.");
      return;
    }

    try {
      // Melanjutkan proses autentikasi jika online
      var isSuccess = await _authService
          .login(
        login: emailController.text,
        password: passwordController.text,
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception("Koneksi ke server terlalu lama (Timeout).");
      });

      if (!isSuccess) {
        // Pesan error jika autentikasi gagal dari server
        Get.dialog(
          AlertDialog(
            title: Text("login_error_title".tr),
            content: Text("login_error_msg".tr),
            actions: [
              TextButton(
                  onPressed: () => Get.back(), child: Text("login_btn_ok".tr)),
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

      // Pengguna tidak perlu menunggu satu per satu selesai.
      await Future.wait([
        // Simpan Kredensial (lokal dan cepat)
        rememberMe.value
            ? _storageService.saveCredentials(
                emailController.text, passwordController.text)
            : _storageService.clearCredentials(),

        // Ambil Profil Kerja (Network Call)
        _workProfileService.fetchProfile(),

        // Inisialisasi Firebase (Async)
        FirebaseService().initialize(),

        // Ambil Notifikasi Awal (Network Call)
        // Bungkus dalam try-catch agar jika notifikasi gagal, login tetap berhasil
        Get.find<NotificationController>().fetchNotifications().catchError((e) {
          return;
        }),
      ]);

      // Navigasi ke dashboard
      Get.offAllNamed('/dashboard');
    } catch (e) {
      String title = "Terjadi Kesalahan";
      String message = "Gagal melakukan login.";

      // Cek pesan error untuk menentukan jenis dialog
      if (e.toString().contains("Gagal terhubung")) {
        title = "Server Tidak Terjangkau";
        message = "Aplikasi tidak dapat terhubung ke server Odoo.";
      }

      // Tampilkan Dialog Warning
      Get.dialog(
        AlertDialog(
          title: Text(title, style: const TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Get.back(), child: const Text("Mengerti")),
          ],
        ),
      );
    }
  }
}
