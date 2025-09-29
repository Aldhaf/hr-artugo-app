// lib/main.dart

import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hr_artugo_app/module/about_app/bindings/about_app_binding.dart';
import 'package:hr_artugo_app/module/about_app/view/about_app_view.dart';
import 'package:hr_artugo_app/module/notification_settings/view/notification_settings_view.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';

// Import semua halaman dan binding yang diperlukan
import 'package:hr_artugo_app/module/notification/bindings/notification_binding.dart';
import 'package:hr_artugo_app/module/notification/controller/notification_controller.dart';
import 'package:hr_artugo_app/module/notification/view/notification_view.dart';
import 'package:hr_artugo_app/module/main_navigation/bindings/main_navigation_binding.dart';
import 'package:hr_artugo_app/service/local_notification_service/local_notification_service.dart';
import 'package:hr_artugo_app/module/time_off_detail/bindings/time_off_detail_binding.dart';
import 'package:hr_artugo_app/module/time_off_detail/view/time_off_detail_view.dart';
import 'package:hr_artugo_app/module/login/binding/login_binding.dart';
import 'package:hr_artugo_app/module/terms_and_conditions/view/terms_view.dart';
import 'package:hr_artugo_app/module/privacy_policy/view/privacy_policy_view.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 3. Perintahkan splash screen native untuk TETAP TAMPIL
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 4. Lakukan semua proses inisialisasi yang butuh waktu di sini
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Anda bisa menambahkan await lain di sini jika perlu
  // await OdooApi.someInitialSetup();
  // await someOtherService.init();

  LocalNotificationService.initialize();
  Get.put(NotificationController(), permanent: true);

  // Jalankan aplikasi
  runApp(const MainApp());

  // 5. SETELAH SEMUANYA SIAP, hapus splash screen
  // Tambahkan sedikit delay untuk memastikan frame pertama sudah ter-render
  Future.delayed(Duration(milliseconds: 200), () {
    FlutterNativeSplash.remove();
  });
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HR Artugo',
      debugShowCheckedModeBanner: false,
      theme: getDefaultTheme(),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const MainNavigationView(),
          binding: MainNavigationBinding(),
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationView(),
          binding: NotificationBinding(),
        ),
        GetPage(
          name: '/time_off_detail', // Nama route baru
          page: () => const TimeOffDetailView(),
          binding: TimeOffDetailBinding(), // Gunakan binding yang sesuai
        ),
        GetPage(
          name: '/about_app', // Nama route baru
          page: () => const AboutAppView(),
          binding: AboutAppBinding(), // Gunakan binding yang sesuai
        ),
        GetPage(
          name: '/notification_settings', // Nama route baru
          page: () => const NotificationSettingsView(),
        ),
        GetPage(
          name: '/terms_and_conditions',
          page: () => const TermsView(),
        ),
        GetPage(
          name: '/privacy_policy',
          page: () => const PrivacyPolicyView(),
        ),
      ],
    );
  }
}
