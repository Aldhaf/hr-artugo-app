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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    // Nonaktifkan Crashlytics saat dalam mode debug
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    // Aktifkan Crashlytics untuk mode release
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // Atur handler untuk menangkap error Flutter
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  LocalNotificationService.initialize();
  Get.put(NotificationController(), permanent: true);

  // Jalankan aplikasi
  runApp(const MainApp());

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
