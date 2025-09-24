// lib/module/login/controller/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:hr_artugo_app/core.dart' hide Get;
import '../../../service/storage_service/storage_service.dart';
import '../../../service/firebase_service/firebase_service.dart';
import '../../../module/notification/controller/notification_controller.dart';
import '../../../service/work_profile_service/work_profile_service.dart';
import '../../../model/work_profile_model.dart';

class LoginController extends GetxController {
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
    try {
      // 1. Lakukan Autentikasi terlebih dahulu
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

      print(
          "Login berhasil, menjalankan tugas-tugas post-login secara berurutan...");

      // 3. Ambil Employee ID
      await OdooApi.getEmployeeId();
      // 4. Inisialisasi Firebase Service
      await FirebaseService().initialize();
      // 5. Daftarkan service profil kerja
      await Get.putAsync(() => WorkProfileService().init());

      // --- TAHAP INVESTIGASI DIMULAI DI SINI ---
      print("[DEBUG] Memanggil OdooApi.getWorkProfile()...");
      final profileData = await OdooApi.getWorkProfile();

      print("=========================================================");
      print("[DEBUG-LOGIN] 1. RAW DATA DARI ODOO API:");
      print(profileData);
      print("[DEBUG-LOGIN] Tipe data mentah: ${profileData.runtimeType}");
      print("=========================================================");

      final workProfile = WorkProfile.fromJson(profileData);

      print("=========================================================");
      print("[DEBUG-LOGIN] 2. DATA SETELAH DI-PARSING MENJADI OBJEK:");
      print("   -> Nama Karyawan: ${workProfile.employeeName}");
      print("   -> Jabatan: ${workProfile.jobTitle}");
      print("=========================================================");
      
      final workProfileService = Get.find<WorkProfileService>();
      workProfileService.setProfile(workProfile);
      print("[DEBUG] Profil kerja telah disimpan di WorkProfileService.");
      // --- AKHIR TAHAP INVESTIGASI ---

      print("Semua tugas post-login selesai.");
      Get.find<NotificationController>().fetchNotifications();
      Get.offAll(const MainNavigationView());
    } catch (e) {
      print("Error selama proses login: $e");
      Get.snackbar("Error", "Terjadi kesalahan saat login: ${e.toString()}");
    }
  }
}
