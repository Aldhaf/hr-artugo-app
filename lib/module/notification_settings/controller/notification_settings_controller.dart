import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsController extends GetxController {
  // Variabel state untuk setiap toggle
  var allNotifications = true.obs;
  var attendanceReminders = true.obs;
  var leaveApprovals = true.obs;
  var announcements = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // Memuat pengaturan dari SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    allNotifications.value = prefs.getBool('allNotifications') ?? true;
    attendanceReminders.value = prefs.getBool('attendanceReminders') ?? true;
    leaveApprovals.value = prefs.getBool('leaveApprovals') ?? true;
    announcements.value = prefs.getBool('announcements') ?? true;
  }

  // Menyimpan pengaturan
  void updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // Update state lokal
    switch (key) {
      case 'allNotifications':
        allNotifications.value = value;
        break;
      case 'attendanceReminders':
        attendanceReminders.value = value;
        break;
      case 'leaveApprovals':
        leaveApprovals.value = value;
        break;
      case 'announcements':
        announcements.value = value;
        break;
    }
  }
}