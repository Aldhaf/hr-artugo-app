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
import 'package:intl/date_symbol_data_local.dart';
import 'package:hr_artugo_app/config/env_dev.dart';
import 'package:hr_artugo_app/shared/localization/app_translations.dart';
import 'package:hr_artugo_app/service/localization_service/localization_service.dart';

import 'package:hr_artugo_app/service/theme_service/theme_service.dart';
import 'package:hr_artugo_app/service/work_profile_service/work_profile_service.dart';
import 'package:hr_artugo_app/service/notification_preference_service/notification_preference_service.dart';
import 'package:hr_artugo_app/service/cache_service/cache_service.dart';
import 'package:hr_artugo_app/service/storage_service/storage_service.dart';
import 'package:hr_artugo_app/service/notification_service/notification_service.dart';
import 'package:hr_artugo_app/module/onboarding/bindings/onboarding_binding.dart';
import 'package:hr_artugo_app/service/connectivity_service/connectivity_service.dart';

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
  // Pastikan Firebase diinisialisasi di dalam handler ini
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initServices() async {
  /*
  // --- GRUP 1: SERVICE DASAR ---
  // Service ini tidak butuh service lain yang kita buat, jadi aman di paling atas.
  await Get.putAsync(() async => OdooApiService(), permanent: true);
  Get.put(CacheService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(NotificationPreferenceService(), permanent: true);
  Get.put(ConnectivityService(), permanent: true);

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

  // --- GRUP 4: CONTROLLER ---
  // Controller biasanya didaftarkan terakhir karena mereka butuh semua service.
  Get.put(NotificationController(), permanent: true);

  // --- Utility (Non-GetX Service) ---
  LocalNotificationService.initialize();
  */

  // --- GRUP 1: Service Inti & Cepat (Diperlukan Paling Awal) ---
  // Service ini tidak memiliki dependensi eksternal yang kompleks atau async init.
  // Ditandai 'permanent' agar tidak dihapus GetX.
  Get.put(StorageService(), permanent: true);
  Get.put(CacheService(), permanent: true);
  Get.put(ConnectivityService(), permanent: true);
  Get.put(NotificationPreferenceService(), permanent: true);

  // --- GRUP 2: Service Kritis untuk Koneksi & Autentikasi ---
  // OdooApiService adalah fondasi, butuh 'await' karena mungkin ada setup async.
  // AuthService bergantung pada OdooApiService, didaftarkan setelahnya (lazyPut OK).
  await Get.putAsync(() async => OdooApiService(), permanent: true);
  Get.lazyPut<AuthService>(() => AuthService(),
      fenix: true); // Fenix & Permanent krn penting

  // --- GRUP 3: Service/Controller yang Diperlukan Segera Setelah Login ---
  // WorkProfile butuh OdooApi dan punya init() async.
  // Notifikasi dibutuhkan segera setelah login untuk mengambil data awal.
  await Get.putAsync(() => WorkProfileService().init(), permanent: true);
  // Daftarkan Service Notifikasi sebelum Controller-nya
  Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
  Get.lazyPut<NotificationController>(() => NotificationController(),
      fenix: true);
  
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  await Get.putAsync(() => LocalizationService().init());

  // --- CATATAN ---
  // Service lain yang BISA ditunda (FirebaseService, AttendanceService, MyScheduleService, dll.)
  // akan tetap diinisialisasi di 'MainNavigationBinding' untuk mempercepat startup awal.
}

void main() async {
  // Panggil fungsi bersama kita dan teruskan konfigurasi 'dev'
  // (Pastikan configDev diimpor dari env_dev.dart)
  await runSharedApp(configDev);
}

Future<void> runSharedApp(Map<String, String> config) async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Get.put<Map<String, String>>(config, permanent: true, tag: 'config');

  await initializeDateFormatting('id_ID', null);

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

  // Inisialisasi ThemeService (cepat karena hanya baca SharedPreferences)
  final themeService = await Get.putAsync(() => ThemeService().init());

  // Cek Onboarding (cepat karena hanya baca SharedPreferences)
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  // Jalankan aplikasi
  runApp(MainApp(
      onboardingCompleted: onboardingCompleted, themeService: themeService));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Hilangkan splash screen setelah UI siap
    FlutterNativeSplash.remove();
  });
}

class MainApp extends StatelessWidget {
  final bool onboardingCompleted;
  final ThemeService themeService;
  const MainApp(
      {Key? key, required this.onboardingCompleted, required this.themeService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = Get.find<LocalizationService>();
    return Obx(() => GetMaterialApp(
          title: 'ArtuGo',
          translations: AppTranslations(), // Kamus bahasa
          locale: localizationService.currentLocale, // Bahasa saat ini
          fallbackLocale: const Locale('en', 'US'),
          debugShowCheckedModeBanner: false,
          theme: getDefaultTheme(),
          darkTheme: getDarkTheme(),
          themeMode: themeService.themeMode,
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
        ));
  }
}
