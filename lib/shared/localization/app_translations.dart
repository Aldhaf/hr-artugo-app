import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Umum
          'hello': 'Hello',
          'loading': 'Loading...',
          'success': 'Success',
          'success_request': 'Schedule request successfully sent.',
          'success_state': 'The schedule request has been canceled.',
          'failed': 'Failed',
          'failed_request': 'Failed to send request:',
          'failed_state': 'Failed to cancel the request:',
          'error': 'Error',
          'error_load_shift':'Failed to load shift list:',
          'cancel': 'Cancel',
          'save': 'Save',
          'confirm': 'Confirm',
          'yes': 'Yes',
          'no': 'No',
          'processing': 'Processing...',
          'processing_state': 'Canceling your request.',
          'confirm_state': 'Are you sure you want to exit the app?',
          'confirm_cancel': 'Yes, Cancel',
          'check_in': 'Check In',
          'today_attend': 'Today Attendance',
          'working_time': 'Working Time',
          'loading_location': 'Loading location...',
          'failed_load_loc': 'Unable to load location',
          'thanks_today': 'Thank you for today!',
          'check_out': 'Check Out',
          'req_schedule_title': 'Pick Date Range',
          'req_schedule_submit': 'Submit Request',
          'req_schedule_select_shift': 'Select Shift',

          // Auth
          'login_welcome_back': 'Welcome Back 👋\nto ',
          'login_subtitle': 'Hello Artlanders!, login to continue',
          'login_email_label': 'Email Address',
          'login_password_label': 'Password',
          'login_remember_me': 'Remember Me',
          'login_btn': 'Login',
          'login_error_title': 'Error', // Tambahan untuk dialog error
          'login_error_msg':
              'Wrong username or password!', // Tambahan untuk dialog error
          'login_btn_ok': 'OK',

          // Dashboard
          'dashboard_total_attendance': 'Total Attendance',
          'dashboard_working_hours': 'Working Hours',
          'dashboard_present': 'Present',
          'dashboard_late': 'Late',
          'dashboard_absent': 'Absent',
          'dashboard_this_month': 'This Month',
          'dashboard_last_month': 'Last Month',
          'dashboard_total_hours': 'Total Hours',
          'dashboard_overtime': 'Overtime',
          'dashboard_apply': 'Apply',
          'dashboard_pick_date_range': 'Pick Date Range',
          'dashboard_no_data': 'No data available for this period.',
          'dashboard_loading_data': 'Loading new data...',
          'dashboard_error_loading': 'An error occurred while loading data.',
          'dashboard_try_again': 'Try Again',
          'dashboard_offline_msg': 'You are offline.',
          'dashboard_offline_cache_msg': 'Offline. Showing cached data.',
          'dashboard_cache_msg': 'Showing cached data.',

          // Location
          'location_title': 'Location Detail',

          // Jadwal Saya
          'my_schedule_title': 'My Schedule',
          'tab_history': 'History & Schedule',
          'tab_request': 'Request Schedule',
          'section_upcoming': 'Upcoming Schedule',
          'section_history': 'Submission History',
          'upcoming_chip': 'Upcoming',
          'filter_days_3': '3 Days',
          'filter_days_7': '7 Days',
          'filter_days_30': '30 Days',
          'empty_upcoming':
              'There are no approved schedules in the next @days days.',
          'search_hint': 'Search',
          'filter_all_months': 'All Months',
          'filter_status_label': 'Status', // Hint untuk dropdown status
          'status_all': 'All Status',
          'status_approved': 'Approved',
          'status_requested': 'Pending',
          'status_rejected': 'Rejected',
          'empty_history':
              'Oppss, there are no submissions matching your filter.',
          'btn_submit_request': 'Submit Schedule Request',
          'btn_cancel': 'CANCEL REQUEST',
          'btn_detail': 'DETAIL',
          'schedule_status_approved': 'APPROVED',
          'schedule_status_requested': 'REQUESTED',
          'schedule_status_rejected': 'REJECTED',
          'schedule_submitted_on':
              'Submitted on: @date', // Gunakan parameter @date
          'schedule_reason': 'Reason: @reason', // Gunakan parameter @reason

          // History Attendance
          'history_attendance_title': 'Attendance History',
          'history_empty': 'No attendance history.',
          'history_no_date': 'No Date',
          'history_check_in': 'Check In',
          'history_check_out': 'Check Out',

          // Profil
          'profile': 'Profile',
          'notification_settings': 'Notification Settings',
          'language': 'Language',
          'dark_mode': 'Dark Mode',
          'about_app': 'About App',
          'terms_conditions': 'Terms & Conditions',
          'privacy_policy': 'Privacy Policy',
          'logout': 'Logout',
          'logout_confirm': 'Are you sure you want to logout?',
          'choose_language': 'Choose Language',
          'error_loading_profile': 'Failed to load profile',

          // Main Navigation
          'nav_dashboard': 'Dashboard',
          'nav_attendance': 'Attendance',
          'nav_timeoff': 'Time Off',
          'nav_schedule': 'Schedule',
          'nav_profile': 'Profile',

          // Rejected Schedule
          'reject_details_title': 'Rejection Details',
          'reject_label_date': 'Date:',
          'reject_label_shift': 'Shift:',
          'reject_label_hours': 'Working Hours:',
          'reject_label_submitted': 'Submitted on:',
          'reject_reason_header': 'Reason for Rejection:',
          'reject_no_reason': 'No reason was specified.',

          // About App
          'about_app_title': 'About App',
          'about_version': 'Version @ver',
          'about_description':
              'Attendance and HR management application for employees.',
          'about_copyright':
              '© 2025 PT Kreasi Arduo Indonesia. All Rights Reserved.',

          // Terms
          'terms_title': 'Terms & Conditions',
          'terms_effective_date': 'Effective per: September 26, 2025',
          'terms_intro':
              'Please read these Terms and Conditions ("Terms") carefully before using the ArtuGo application ("Service") operated by PT Artugo ("Us").\n\nYour access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all employees, users, and others who access or use the Service.\n\nBy accessing or using the Service, you agree to be bound by these Terms. If you disagree with any part of the terms then you may not access the Service.',
          'terms_sec1_title': '1. Service Description',
          'terms_sec1_content':
              'ArtuGo is an internal Human Resource Information System (HRIS) application designed to facilitate and simplify employee administration processes, including but not limited to:\n- Attendance recording (check-in and check-out).\n- Leave application management (time off).\n- Viewing attendance history.\n- Receiving internal company notifications and announcements.',
          'terms_sec2_title': '2. User Accounts',
          'terms_sec2_content':
              'To use the Service, you will be provided with a user account integrated with the central HR system (Odoo). You are responsible for maintaining the confidentiality of your account information, including your password. You agree to accept full responsibility for all activities that occur under your account.',
          'terms_sec3_title': '3. User Obligations',
          'terms_sec3_content':
              'As a user of the Service, you agree to:\n- Provide accurate, current, and complete information at all times.\n- Use the attendance recording feature (check-in/check-out) only at designated work locations and times.\n- Not misuse the Service for fraudulent purposes or other illegal activities.\n- Not attempt to engineer, modify, or access data that is not your right.',
          'terms_sec4_title': '4. Termination of Access',
          'terms_sec4_content':
              'We may terminate or suspend your access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
          'terms_sec5_title': '5. Governing Law',
          'terms_sec5_content':
              'These Terms shall be governed and construed in accordance with the laws of the Republic of Indonesia.',
          'terms_sec6_title': '6. Contact Us',
          'terms_sec6_content':
              'If you have any questions about these Terms, please contact the HR Department.',

          // Privacy & Policy
          'privacy_title': 'Privacy Policy',
          'privacy_effective_date': 'Effective per: September 26, 2025',
          'privacy_intro':
              'PT Artugo ("Us", "We", or "Our") operates the ArtuGo application ("Service"). This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.\n\nWe use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy.',
          'privacy_sec1_title': '1. Information Collection and Use',
          'privacy_sec1_content':
              'We collect several different types of information for various purposes to provide and improve our Service to you.\n\nTypes of Data Collected:\n- Personal Data: Full Name, Employee ID, and Job Title.\n- Location Data (Geolocation): Your GPS coordinates when you perform check-in and check-out actions.\n- Device Data: FCM Token for push notification delivery purposes.',
          'privacy_sec2_title': '2. Use of Data',
          'privacy_sec2_content':
              'PT Artugo uses the collected data for various purposes:\n- To provide and maintain the Service.\n- To manage and verify employee attendance data.\n- To send notifications and important work-related communications.',
          'privacy_sec3_title': '3. Data Security',
          'privacy_sec3_content':
              'The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
          'privacy_sec4_title': '4. Service Providers',
          'privacy_sec4_content':
              'We may employ third party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used.\n- Google Firebase: For push notification services.\n- OpenStreetMap: For mapping services.',
          'privacy_sec5_title': '5. Contact Us',
          'privacy_sec5_content':
              'If you have any questions about this Privacy Policy, please contact the HR Department.',

          // Notification Setting
          'settings_notif_title': 'Notification Settings',
          'settings_notif_all': 'All Notifications',
          'settings_notif_all_desc': 'Enable or disable all notifications',
          'settings_notif_attendance': 'Attendance Reminder',
          'settings_notif_attendance_desc':
              'Daily reminder for check-in and check-out',
          'settings_notif_leave': 'Leave Approval',
          'settings_notif_leave_desc': 'When leave is approved or rejected',
          'settings_notif_announcement': 'Announcements',
          'settings_notif_announcement_desc':
              'When there is a new announcement from HR',

          // Notification
          'notification_page_title': 'Notifications',
          'notification_empty': 'No notifications',
          'delete_action': 'Delete',
          'deleted_success_title': 'Deleted',
          'deleted_success_msg': "'@title' has been deleted.",
        },
        'id_ID': {
          // Umum
          'hello': 'Halo',
          'loading': 'Memuat...',
          'success': 'Berhasil',
          'success_request': 'Pengajuan jadwal berhasil dikirim.',
          'success_state': 'Pengajuan jadwal telah dibatalkan.',
          'failed': 'Gagal',
          'failed_request': 'Gagal mengirim pengajuan:',
          'failed_state': 'Gagal membatalkan pengajuan:',
          'error': 'Kesalahan',
          'error_load_shift':'Gagal memuat daftar shift:',
          'cancel': 'Batal',
          'save': 'Simpan',
          'confirm': 'Konfirmasi',
          'yes': 'Ya',
          'no': 'Tidak',
          'processing': 'Memproses...',
          'processing_state': 'Sedang membatalkan pengajuan Anda.',
          'confirm_state': 'Apakah Anda yakin ingin keluar dari aplikasi?',
          'confirm_cancel': 'Ya, Batalkan',
          'check_in': 'Masuk',
          'check_out': 'Keluar',
          'today_attend': 'Kehadiran Hari Ini',
          'working_time': 'Jam Kerja',
          'loading_location': 'Memuat lokasi...',
          'failed_load_loc': 'Gagal memuat lokasi',
          'thanks_today': 'Terima Kasih untuk Hari Ini!',
          'req_schedule_title': 'Pilih Rentang Tanggal',
          'req_schedule_submit': 'Kirim Pengajuan',
          'req_schedule_select_shift': 'Pilih Shift',

          // Auth
          'login_welcome_back': 'Selamat Datang Kembali 👋\ndi ',
          'login_subtitle': 'Halo Artlanders!, masuk untuk melanjutkan',
          'login_email_label': 'Alamat Email',
          'login_password_label': 'Kata Sandi',
          'login_remember_me': 'Ingat Saya',
          'login_btn': 'Masuk',
          'login_error_title': 'Kesalahan',
          'login_error_msg': 'Email atau kata sandi salah!',
          'login_btn_ok': 'OK',

          // Dashboard
          'dashboard_total_attendance': 'Total Kehadiran',
          'dashboard_working_hours': 'Jam Kerja',
          'dashboard_present': 'Hadir',
          'dashboard_late': 'Terlambat',
          'dashboard_absent': 'Absen',
          'dashboard_this_month': 'Bulan Ini',
          'dashboard_last_month': 'Bulan Lalu',
          'dashboard_total_hours': 'Total Jam',
          'dashboard_overtime': 'Lembur',
          'dashboard_apply': 'Terapkan',
          'dashboard_pick_date_range': 'Pilih Rentang Tanggal',
          'dashboard_no_data': 'Tidak ada data untuk periode ini.',
          'dashboard_loading_data': 'Memuat data baru...',
          'dashboard_error_loading': 'Terjadi kesalahan saat memuat data.',
          'dashboard_try_again': 'Coba Lagi',
          'dashboard_offline_msg': 'Anda sedang offline.',
          'dashboard_offline_cache_msg': 'Offline. Menampilkan data terakhir.',
          'dashboard_cache_msg': 'Menampilkan data cache.',

          // Jadwal Saya
          'my_schedule_title': 'Jadwal Saya',
          'tab_history': 'Riwayat & Jadwal',
          'tab_request': 'Ajukan Jadwal',
          'section_upcoming': 'Jadwal Terdekat',
          'section_history': 'Riwayat Pengajuan',
          'upcoming_chip': 'Mendatang',
          'filter_days_3': '3 Hari',
          'filter_days_7': '7 Hari',
          'filter_days_30': '30 Hari',
          'empty_upcoming':
              'Tidak ada jadwal yang disetujui dalam @days hari ke depan.',
          'search_hint': 'Cari',
          'filter_all_months': 'Semua Bulan',
          'filter_status_label': 'Status',
          'status_all': 'Semua Status',
          'status_approved': 'Disetujui',
          'status_requested': 'Menunggu',
          'status_rejected': 'Ditolak',
          'empty_history':
              'Ups, tidak ada pengajuan yang cocok dengan filter Anda.',
          'btn_submit_request': 'Kirim Pengajuan Jadwal',
          'btn_cancel': 'BATALKAN',
          'btn_detail': 'DETAIL',
          'schedule_status_approved': 'DISETUJUI',
          'schedule_status_requested': 'DIAJUKAN',
          'schedule_status_rejected': 'DITOLAK',
          'schedule_submitted_on': 'Diajukan: @date',
          'schedule_reason': 'Alasan: @reason',

          // History Attendance
          'history_attendance_title': 'Riwayat Absensi',
          'history_empty': 'Tidak ada riwayat absensi.',
          'history_no_date': 'Tanpa Tanggal',
          'history_check_in': 'Masuk',
          'history_check_out': 'Keluar',

          // Profil
          'profile': 'Profil',
          'notification_settings': 'Pengaturan Notifikasi',
          'language': 'Bahasa',
          'dark_mode': 'Mode Gelap',
          'about_app': 'Tentang Aplikasi',
          'terms_conditions': 'Syarat & Ketentuan',
          'privacy_policy': 'Kebijakan Privasi',
          'logout': 'Keluar',
          'logout_confirm': 'Apakah Anda yakin ingin keluar?',
          'error_loading_profile': 'Gagal Memuat Profile',

          // Main Navigation
          'nav_dashboard': 'Beranda',
          'nav_attendance': 'Absensi',
          'nav_timeoff': 'Cuti',
          'nav_schedule': 'Jadwal',
          'nav_profile': 'Profil',

          // Rejected Schedule
          'reject_details_title': 'Detail Penolakan',
          'reject_label_date': 'Tanggal:',
          'reject_label_shift': 'Shift:',
          'reject_label_hours': 'Jam Kerja:',
          'reject_label_submitted': 'Diajukan Pada:',
          'reject_reason_header': 'Alasan Penolakan:',
          'reject_no_reason': 'Tidak ada alasan yang diberikan.',

          // About App
          'about_app_title': 'Tentang Aplikasi',
          'about_version': 'Versi @ver',
          'about_description':
              'Aplikasi absensi dan manajemen HR untuk karyawan.',
          'about_copyright':
              '© 2025 PT Kreasi Arduo Indonesia. Hak Cipta Dilindungi.',

          // Syarat dan Ketentuan
          'terms_title': 'Syarat & Ketentuan',
          'terms_effective_date': 'Efektif per: 26 September 2025',
          'terms_intro':
              'Harap baca Syarat dan Ketentuan Layanan ("Ketentuan") ini dengan saksama sebelum menggunakan aplikasi ArtuGo ("Layanan") yang dioperasikan oleh PT Artugo ("Kami").\n\nAkses Anda ke dan penggunaan Layanan ini mengkondisikan penerimaan dan kepatuhan Anda terhadap Ketentuan ini. Ketentuan ini berlaku untuk semua karyawan, pengguna, dan pihak lain yang mengakses atau menggunakan Layanan.\n\nDengan mengakses atau menggunakan Layanan, Anda setuju untuk terikat oleh Ketentuan ini. Jika Anda tidak setuju dengan bagian mana pun dari ketentuan ini, maka Anda tidak dapat mengakses Layanan.',
          'terms_sec1_title': '1. Deskripsi Layanan',
          'terms_sec1_content':
              'ArtuGo adalah aplikasi Sistem Informasi Sumber Daya Manusia (HRIS) internal yang dirancang untuk memfasilitasi dan menyederhanakan proses administrasi karyawan, termasuk namun tidak terbatas pada:\n- Pencatatan kehadiran (check-in dan check-out).\n- Manajemen pengajuan cuti (time off).\n- Melihat riwayat absensi.\n- Menerima notifikasi dan pengumuman internal perusahaan.',
          'terms_sec2_title': '2. Akun Pengguna',
          'terms_sec2_content':
              'Untuk menggunakan Layanan, Anda akan diberikan akun pengguna yang terintegrasi dengan sistem HR pusat (Odoo). Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk kata sandi. Anda setuju untuk menerima tanggung jawab penuh atas semua aktivitas yang terjadi di bawah akun Anda.',
          'terms_sec3_title': '3. Kewajiban Pengguna',
          'terms_sec3_content':
              'Sebagai pengguna Layanan, Anda setuju untuk:\n- Memberikan informasi yang akurat, terkini, dan lengkap setiap saat.\n- Menggunakan fitur pencatatan kehadiran (check-in/check-out) hanya pada lokasi dan waktu kerja yang telah ditentukan.\n- Tidak menyalahgunakan Layanan untuk tujuan penipuan atau aktivitas ilegal lainnya.\n- Tidak mencoba merekayasa, memodifikasi, atau mengakses data yang bukan hak Anda.',
          'terms_sec4_title': '4. Penghentian Akses',
          'terms_sec4_content':
              'Kami dapat menghentikan atau menangguhkan akses Anda ke Layanan kami dengan segera, tanpa pemberitahuan atau kewajiban sebelumnya, untuk alasan apa pun, termasuk namun tidak terbatas pada pelanggaran Ketentuan ini.',
          'terms_sec5_title': '5. Hukum yang Berlaku',
          'terms_sec5_content':
              'Ketentuan ini akan diatur dan ditafsirkan sesuai dengan hukum yang berlaku di Republik Indonesia.',
          'terms_sec6_title': '6. Hubungi Kami',
          'terms_sec6_content':
              'Jika Anda memiliki pertanyaan tentang Ketentuan ini, silakan hubungi Departemen HR.',

          // Privasi & Kebijakan
          'privacy_title': 'Kebijakan Privasi',
          'privacy_effective_date': 'Efektif per: 26 September 2025',
          'privacy_intro':
              'PT Artugo ("Kami") mengoperasikan aplikasi ArtuGo ("Layanan"). Kebijakan Privasi ini memberi tahu Anda tentang kebijakan kami mengenai pengumpulan, penggunaan, dan pengungkapan data pribadi saat Anda menggunakan Layanan kami.\n\nKami menggunakan data Anda untuk menyediakan dan meningkatkan Layanan. Dengan menggunakan Layanan, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini.',
          'privacy_sec1_title': '1. Pengumpulan dan Penggunaan Informasi',
          'privacy_sec1_content':
              'Kami mengumpulkan beberapa jenis informasi untuk berbagai tujuan guna menyediakan dan meningkatkan Layanan kami kepada Anda.\n\nJenis Data yang Dikumpulkan:\n- Data Identifikasi Pribadi: Nama Lengkap, ID Karyawan, dan Jabatan.\n- Data Lokasi (Geolocation): Koordinat GPS Anda saat Anda melakukan aksi check-in dan check-out.\n- Data Perangkat: FCM Token untuk tujuan pengiriman notifikasi push.',
          'privacy_sec2_title': '2. Penggunaan Data',
          'privacy_sec2_content':
              'PT Artugo menggunakan data yang dikumpulkan untuk berbagai tujuan:\n- Untuk menyediakan dan memelihara Layanan.\n- Untuk mengelola dan memverifikasi data kehadiran karyawan.\n- Untuk mengirimkan notifikasi dan komunikasi penting terkait pekerjaan.',
          'privacy_sec3_title': '3. Keamanan Data',
          'privacy_sec3_content':
              'Keamanan data Anda penting bagi kami. Kami berusaha untuk menggunakan cara yang dapat diterima secara komersial untuk melindungi Data Pribadi Anda. Namun, harap diingat bahwa tidak ada metode transmisi melalui Internet atau metode penyimpanan elektronik yang 100% aman.',
          'privacy_sec4_title': '4. Penyedia Layanan Pihak Ketiga',
          'privacy_sec4_content':
              'Kami dapat menggunakan penyedia layanan pihak ketiga untuk memfasilitasi Layanan kami ("Penyedia Layanan"), seperti:\n- Google Firebase: Untuk layanan notifikasi push (Firebase Cloud Messaging).\n- OpenStreetMap: Untuk layanan pemetaan dan konversi koordinat menjadi alamat.',
          'privacy_sec5_title': '5. Hubungi Kami',
          'privacy_sec5_content':
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi Departemen HR.',

          // Pengaturan Notifikasi
          'settings_notif_title': 'Pengaturan Notifikasi',
          'settings_notif_all': 'Semua Notifikasi',
          'settings_notif_all_desc':
              'Aktifkan atau nonaktifkan semua notifikasi',
          'settings_notif_attendance': 'Pengingat Absensi',
          'settings_notif_attendance_desc':
              'Notifikasi harian untuk check-in dan check-out',
          'settings_notif_leave': 'Persetujuan Cuti',
          'settings_notif_leave_desc': 'Saat cuti disetujui atau ditolak',
          'settings_notif_announcement': 'Pengumuman',
          'settings_notif_announcement_desc':
              'Saat ada pengumuman baru dari HR',

          // Notifikasi
          'notification_page_title': 'Notifikasi',
          'notification_empty': 'Tidak ada notifikasi',
          'delete_action': 'Hapus',
          'deleted_success_title': 'Dihapus',
          'deleted_success_msg': "'@title' telah dihapus.",
        }
      };
}
