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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hr_artugo_app/service/local_notification_service/local_notification_service.dart';
import 'package:hr_artugo_app/service/work_profile_service/work_profile_service.dart';
import 'package:hr_artugo_app/service/firebase_service/firebase_service.dart';
import 'package:hr_artugo_app/service/notification_preference_service/notification_preference_service.dart';
import 'package:hr_artugo_app/service/leave_type_service/leave_type_service.dart';
import 'package:hr_artugo_app/service/time_off_service/time_off_service.dart';
import 'package:hr_artugo_app/service/my_schedule_service/my_schedule_service.dart';
import 'package:hr_artugo_app/service/cache_service/cache_service.dart';
import 'package:hr_artugo_app/service/storage_service/storage_service.dart';
import 'package:hr_artugo_app/service/notification_service/notification_service.dart';
import 'package:hr_artugo_app/module/onboarding/bindings/onboarding_binding.dart';

import 'package:hr_artugo_app/module/notification/bindings/notification_binding.dart';
import 'package:hr_artugo_app/module/notification/controller/notification_controller.dart';
import 'package:hr_artugo_app/module/notification/view/notification_view.dart';
import 'package:hr_artugo_app/module/main_navigation/bindings/main_navigation_binding.dart';
import 'package:hr_artugo_app/module/time_off_detail/bindings/time_off_detail_binding.dart';
import 'package:hr_artugo_app/module/time_off_detail/view/time_off_detail_view.dart';
import 'package:hr_artugo_app/module/login/binding/login_binding.dart';
import 'package:hr_artugo_app/module/terms_and_conditions/view/terms_view.dart';
import 'package:hr_artugo_app/module/privacy_policy/view/privacy_policy_view.dart';
import 'package:hr_artugo_app/module/my_schedule/bindings/my_schedule_binding.dart';
import 'package:hr_artugo_app/module/my_schedule/view/my_schedule_view.dart';
import 'package:hr_artugo_app/module/onboarding/view/onboarding_view.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase sudah diinisialisasi di sini juga untuk background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");

  if (message.data['type'] == 'schedule_update') {
    print("Trigger 'schedule_update' diterima di background.");
    if (Get.isRegistered<DashboardController>()) {
      final dashboardController = Get.find<DashboardController>();
      await dashboardController.refreshData();
      print("Dashboard data refreshed from background trigger.");
    }
  }
}

Future<void> initServices() async {
  // --- GRUP 1: SERVICE DASAR (TANPA DEPENDENSI INTERNAL) ---
  // Service ini tidak butuh service lain yang kita buat, jadi aman di paling atas.
  await Get.putAsync(() async => OdooApiService(), permanent: true);
  Get.put(CacheService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(NotificationPreferenceService(), permanent: true);

  // --- GRUP 2: SERVICE YANG BUTUH GRUP 1 ---
  // Service ini butuh service dari grup di atasnya.
  Get.put(AuthService(), permanent: true);
  Get.put(WorkProfileService(),
      permanent: true); // Butuh OdooApiService & CacheService
  Get.put(FirebaseService(),
      permanent: true); // Butuh NotificationPreferenceService & OdooApiService
  Get.put(LeaveTypeService(), permanent: true);
  Get.put(TimeOffService(), permanent: true);
  Get.put(MyScheduleService(), permanent: true);
  Get.put(NotificationService(), permanent: true);

  // --- GRUP 3: SERVICE YANG BUTUH GRUP 2 ---
  // AttendanceService butuh WorkProfileService, jadi harus setelahnya.
  Get.put(AttendanceService(), permanent: true);

  // --- GRUP 4: CONTROLLER (YANG DI-INIT DI AWAL) ---
  // Controller biasanya didaftarkan terakhir karena mereka butuh semua service.
  Get.put(NotificationController(), permanent: true);

  // --- Utility (Non-GetX Service) ---
  LocalNotificationService.initialize();
  print("All services initialized successfully in the correct order.");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Atur Crashlytics
  if (kDebugMode) {
    // Nonaktifkan Crashlytics saat dalam mode debug
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    // Aktifkan Crashlytics untuk mode release
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // Atur handler untuk menangkap error Flutter
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  await initServices();

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  // Jalankan aplikasi
  runApp(MainApp(onboardingCompleted: onboardingCompleted));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Hilangkan splash screen setelah UI siap
    FlutterNativeSplash.remove();
  });
}

class MainApp extends StatelessWidget {
  final bool onboardingCompleted;
  const MainApp({Key? key, required this.onboardingCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HR Artugo',
      debugShowCheckedModeBanner: false,
      theme: getDefaultTheme(),
      initialRoute: onboardingCompleted ? '/login' : '/onboarding',
      getPages: [
        GetPage(
          name: '/onboarding', // Gunakan string biasa
          page: () => const OnboardingView(),
          binding: OnboardingBinding(),
        ),
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
          name: '/time_off_detail',
          page: () => const TimeOffDetailView(),
          binding: TimeOffDetailBinding(),
        ),
        GetPage(
          name: '/about_app',
          page: () => const AboutAppView(),
          binding: AboutAppBinding(),
        ),
        GetPage(
          name: '/notification_settings',
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
        GetPage(
          name: '/my_schedule',
          page: () => const MyScheduleView(),
          binding: MyScheduleBinding(),
        ),
      ],
    );
  }
}
