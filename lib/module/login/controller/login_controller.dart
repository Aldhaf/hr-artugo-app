// lib/module/login/controller/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/storage_service/storage_service.dart';
import '../../../service/firebase_service/firebase_service.dart';
import '../../../module/notification/controller/notification_controller.dart';

class LoginController extends GetxController {
  // <-- Ubah menjadi GetxController
  final _storageService = StorageService();

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
    // Tampilkan dialog loading atau state loading di sini jika perlu
    try {
      var isSuccess = await AuthService().login(
        login: emailController.text,
        password: passwordController.text,
      );

      if (!isSuccess) {
        Get.dialog(
          AlertDialog(
            title: const Text("Error"),
            content: const Text("Wrong username or password!"),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      // Proses logika "Remember Me" (ini cepat, jadi tidak perlu diubah)
      if (rememberMe.value) {
        await _storageService.saveCredentials(
            emailController.text, passwordController.text);
      } else {
        await _storageService.clearCredentials();
      }

      print(
          "Login berhasil, menjalankan tugas-tugas post-login secara paralel...");

      // --- INTI OPTIMASI ---
      // Jalankan semua tugas yang butuh jaringan secara bersamaan
      await Future.wait<dynamic>([
        // Tambahkan <dynamic> di sini
        // Tugas 1: Inisialisasi Firebase (mengambil & menyimpan token FCM)
        FirebaseService().initialize(),
        // Tugas 2: Ambil data Employee ID dari Odoo
        OdooApi.getEmployeeId(),
      ]);

      print("Semua tugas post-login selesai.");

      // Setelah semua siap, baru muat notifikasi dan pindah halaman
      Get.find<NotificationController>().fetchNotifications();
      Get.offAll(MainNavigationView());
    } catch (e) {
      // Tangani error lain yang mungkin terjadi
      print("Error selama proses login: $e");
      Get.snackbar("Error", "Terjadi kesalahan saat login.");
    } finally {
      // Sembunyikan dialog loading atau state loading di sini
    }
  }
}
