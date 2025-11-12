import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:odoo_rpc/odoo_rpc.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class OdooApiService {
  final Map<String, String> _config =
      Get.find<Map<String, String>>(tag: 'config');

  late OdooClient client;
  OdooSession? session;
  int? employeeId;
  late final Dio _dio;

  OdooApiService() {
    final host = _config['host'];
    if (host == null) {
      throw Exception(
          "Config 'host' not found. Make sure config is passed to runSharedApp.");
    }
    client = OdooClient(host);
    _dio = Dio(BaseOptions(
      baseUrl: host,
    ));
    print(
        "OdooApiService Initialized for env: ${_config['env']} at host: $host");
  }

  // Mengirimkan pengajuan jadwal bulanan yang dipilih pengguna ke API Odoo.
  Future<void> submitMonthlyRoster(Map<String, dynamic> data) async {
    // Path endpoint yang ada di Odoo
    const String path = '/api/submit_monthly_roster';
    final String? sessionId = session?.id;
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan, harap login ulang.");
    }

    try {
      // Melakukan panggilan POST dengan Dio/http
      final Response response = await _dio.post(
        path,
        data: {'params': data},
        options: Options(
          headers: {
            'Cookie': 'session_id=$sessionId',
          },
        ),
      );

      if (response.statusCode != 200 ||
          (response.data is Map && response.data['error'] != null)) {
        throw Exception(
            "Gagal mengirim pengajuan bulanan: ${response.data['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Mengambil daftar tanggal yang sudah terisi jadwal (approved/requested) dari API Odoo untuk bulan tertentu.
  Future<List<dynamic>> getBookedDates(String startDate, String endDate) async {
    const String path = '/api/get_booked_dates';
    final String? sessionId = session?.id;
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }

    try {
      final response = await _dio.post(
        path,
        data: {
          'params': {
            'start_date': startDate,
            'end_date': endDate,
          }
        },
        options: Options(headers: {'Cookie': 'session_id=$sessionId'}),
      );

      if (response.data != null &&
          response.data['result']?['booked_dates'] is List) {
        return response.data['result']['booked_dates'] as List<dynamic>;
      } else {
        // Jika format tidak sesuai, kembalikan list kosong agar tidak error
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  // Membatalkan pengajuan jadwal (roster) yang masih berstatus 'requested' melalui API Odoo.
  Future<void> cancelShiftRequest(int rosterId) async {
    final url = "${_config['host']!}/api/cancel_shift_request";
    final dio = Dio();
    final String? sessionId = session?.id;
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }
    dio.options.headers['Cookie'] = 'session_id=$sessionId';

    try {
      final response = await dio.post(url, data: {
        'params': {
          'roster_id': rosterId,
        }
      });

      // Periksa apakah ada pesan error dari server
      if (response.data['result'] != null &&
          response.data['result']['error'] != null) {
        throw Exception(response.data['result']['error']);
      }
      if (response.data['result'] == null ||
          response.data['result']['success'] != true) {
        throw Exception("Gagal membatalkan jadwal di server.");
      }
    } on DioException catch (e) {
      throw Exception("Gagal terhubung ke server: ${e.message}");
    }
  }

  // Mengambil daftar pola kerja (shift) yang tersedia untuk dipilih oleh karyawan dari API Odoo.
  Future<List<dynamic>> getAvailableShifts() async {
    final url = "${_config['host']!}/api/get_available_shifts";
    final dio = Dio();
    final String? sessionId = session?.id;

    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }
    dio.options.headers['Cookie'] = 'session_id=$sessionId';

    try {
      final response = await dio.post(url, data: {});
      // API sekarang mengembalikan map dengan key 'shifts' di dalam 'result'
      if (response.data['result'] != null &&
          response.data['result']['shifts'] != null) {
        return response.data['result']['shifts'] as List<dynamic>;
      }
      return []; // Kembalikan list kosong jika tidak ada data
    } on DioException catch (e) {
      throw Exception("Gagal memuat daftar shift.");
    }
  }

  // Mencatat absensi check-in karyawan ke Odoo melalui API custom, menyertakan data GPS.
  Future<void> createAttendanceWithGPS({
    required Position position,
  }) async {
    final url = "${_config['host']!}/api/hr_attendance/check_in";
    final String? sessionId = session?.id;

    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan. Silakan coba login ulang.");
    }

    try {
      // Gunakan FormData untuk mengirim data non-file
      FormData formData = FormData.fromMap({
        'employee_id': employeeId,
        'check_in_latitude': position.latitude,
        'check_in_longitude': position.longitude,
      });

      final dio = Dio();
      dio.options.headers['Cookie'] = 'session_id=$sessionId';

      final response = await dio.post(url, data: formData);

      // Menambahkan pengecekan status respons dari Odoo
      if (response.statusCode != 200) {
        throw Exception(response.data.toString());
      }
    } on DioException catch (e) {
      // Membuat pesan error lebih informatif
      final errorMessage = e.response?.data?.toString() ?? e.message;
      throw Exception("Gagal terhubung ke server: $errorMessage");
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  // Mengambil daftar semua pola kerja (shift) yang terdefinisi di Odoo.
  Future<List<dynamic>> getWorkPatterns() async {
    // Gunakan method 'get' yang sudah ada
    return await get(
      model: 'hr.work.pattern',
      fields: ['id', 'name'],
    );
  }

  // Mengirimkan pengajuan jadwal shift individual ke API Odoo (kemungkinan deprecated, digantikan submitMonthlyRoster).
  Future<Map<String, dynamic>> submitShiftRequest(
      List<Map<String, dynamic>> schedules) async {
    final url = "${_config['host']!}/api/submit_shift_request";
    final dio = Dio();
    final String? sessionId = session?.id;

    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }
    dio.options.headers['Cookie'] = 'session_id=$sessionId';

    try {
      final response = await dio.post(url, data: {
        'params': {'schedules': schedules}
      });
      // Langsung return response.data karena tidak dibungkus 'result'
      return response.data['result'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception("Gagal mengirim pengajuan jadwal.");
    }
  }

  // Mengambil riwayat pengajuan jadwal (roster) milik karyawan yang sedang login dari API Odoo.
  Future<List<dynamic>> getMyRoster() async {
    final url = "${_config['host']!}/api/get_my_roster";
    final dio = Dio();
    final String? sessionId = session?.id;

    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }
    dio.options.headers['Cookie'] = 'session_id=$sessionId';

    try {
      final response = await dio.post(url, data: {});
      final result = response.data['result'];
      if (result != null && result['rosters'] is List) {
        return result['rosters'] as List<dynamic>;
      }
      // Jika tidak ada data atau format salah, kembalikan list kosong
      return [];
    } on DioException catch (e) {
      throw Exception("Gagal mengambil riwayat jadwal.");
    }
  }

  // Mengambil data rekap jam kerja harian dari API Odoo untuk rentang tanggal tertentu (untuk chart).
  Future<Map<String, dynamic>> getDailyWorkedHours(
      String startDate, String endDate) async {
    const String path = '/api/get_daily_hours';
    final String? sessionId = session?.id;
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }

    try {
      final response = await _dio.post(
        path,
        data: {
          // Odoo butuh params
          'params': {
            'start_date': startDate,
            'end_date': endDate,
          }
        },
        options: Options(
          headers: {
            'Cookie': 'session_id=$sessionId',
          },
        ),
      );

      // Mengembalikan response.data['result']
      if (response.data != null && response.data['result'] != null) {
        return response.data['result'] as Map<String, dynamic>;
      } else {
        throw Exception("Format respons API tidak valid.");
      }
    } catch (e) {
      rethrow;
    }
  }

  // Mengambil data profil kerja karyawan (termasuk jadwal kerja default) dari API Odoo.
  Future<Map<String, dynamic>> getWorkProfile() async {
    final url = "${_config['host']!}/api/get_work_profile";
    final dio = Dio();
    final String? sessionId = session?.id;

    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan.");
    }
    dio.options.headers['Cookie'] = 'session_id=$sessionId';

    try {
      final response = await dio.post(url, data: {});
      if (response.data['result'] != null) {
        return response.data['result'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw Exception("Gagal memuat profil kerja: ${e.response?.data}");
    }
  }

  // Mencatat absensi check-in ke Odoo melalui API custom, menyertakan data GPS dan foto.
  Future<void> createAttendanceWithPhoto({
    required Position position,
    required File photo,
  }) async {
    final url = "${_config['host']!}/api/hr_attendance/check_in";

    // Mengambil ID sesi (dalam bentuk String) dari objek sesi yang disimpan saat login.
    final String? sessionId = session?.id;

    // Melakukan pengecekan yang lebih ketat
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan. Silakan coba login ulang.");
    }

    try {
      String fileName = photo.path.split('/').last;
      FormData formData = FormData.fromMap({
        'employee_id': employeeId,
        'check_in_latitude': position.latitude,
        'check_in_longitude': position.longitude,
        'check_in_photo': await MultipartFile.fromFile(
          photo.path,
          filename: fileName,
        ),
      });

      final dio = Dio();

      // Set header Cookie dengan session ID yang sudah diverifikasi
      dio.options.headers['Cookie'] = 'session_id=$sessionId';

      print("Mengirim data absensi ke: $url");
      await dio.post(url, data: formData);
      print("Data absensi berhasil dikirim.");
    } on DioException catch (e) {
      print("--- Dio Error on Upload ---");
      print("Error: ${e.message}");
      print("Response: ${e.response?.data}");
      print("--------------------------");

      // Periksa jika error disebabkan oleh redirect lagi
      if (e.response?.statusCode == 302) {
        throw Exception(
            "Otentikasi gagal. Sesi Anda mungkin sudah habis. Coba login ulang.");
      }
      throw Exception("Gagal terhubung ke server saat mengirim absensi.");
    } catch (e) {
      print("Error tidak terduga saat upload: $e");
      throw Exception("Terjadi kesalahan tidak terduga saat upload.");
    }
  }

  // Menghasilkan URL gambar profil pengguna Odoo berdasarkan ID pengguna.
  String? getUserImageUrl(int uid) {
    return "${_config['host']!}/web/image?model=res.users&id=$uid&field=image_1920";
  }

  // Menghapus notifikasi spesifik dari Odoo berdasarkan ID notifikasi.
  Future<bool> deleteNotification(int id) async {
    try {
      final response = await client.callKw({
        'model': 'hr.notification',
        'method': 'unlink',
        'args': [
          [id]
        ],
        'kwargs': {},
      });
      print("Notifikasi ID $id berhasil dihapus dari server.");
      return response as bool? ?? false;
    } catch (e) {
      print("Gagal menghapus notifikasi ID $id: $e");
      return false;
    }
  }

  // Mengambil detail data pengajuan cuti (hr.leave) dari Odoo berdasarkan ID pengajuan.
  Future<Map<String, dynamic>?> getTimeOffDetail(int id) async {
    try {
      final response = await client.callKw({
        'model': 'hr.leave',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', '=', id]
          ], // Filter berdasarkan ID yang spesifik
          'fields': [
            'display_name',
            'date_from',
            'date_to',
            'number_of_days',
            'state',
            'holiday_status_id', // Tipe Cuti
          ],
          'limit': 1,
        },
      });
      // search_read mengembalikan list, kita ambil elemen pertamanya
      if (response is List && response.isNotEmpty) {
        // Print di sini untuk debugging
        print("Data cuti yang diterima dari Odoo: ${response[0]}");
        return response[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Gagal mengambil detail Time Off: $e");
      return null;
    }
  }

  // Menandai satu atau beberapa notifikasi sebagai sudah dibaca di Odoo berdasarkan ID notifikasi.
  Future<void> markNotificationsAsRead(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      // Menggunakan 'callKw'
      await client.callKw({
        'model': 'hr.notification',
        'method': 'write', // method 'write' di sini
        'args': [
          ids,
          {'is_read': true}
        ],
        'kwargs': {},
      });
      print("Menandai notifikasi ${ids.toString()} sebagai sudah dibaca.");
    } catch (e) {
      print("Gagal menandai notifikasi sebagai sudah dibaca: $e");
    }
  }

  // Mengambil daftar notifikasi milik pengguna yang sedang login dari Odoo.
  Future<List<dynamic>> fetchNotifications() async {
    final uid = session?.userId;
    if (uid == null) {
      print("Tidak bisa mengambil notifikasi, user belum login.");
      return [];
    }

    try {
      final response = await client.callKw({
        'model': 'hr.notification',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['user_id', '=', uid]
          ], // Filter hanya untuk user ini
          'fields': [
            'id',
            'name', // Ini akan menjadi 'title'
            'body',
            'create_date',
            'is_read',
            'type',
            'related_id'
          ],
          'order': 'create_date DESC', // Tampilkan yang terbaru di atas
        },
      });
      return response as List<dynamic>? ?? [];
    } catch (e) {
      print("Gagal mengambil notifikasi dari Odoo: $e");
      return [];
    }
  }

  // Menyimpan atau memperbarui token Firebase Cloud Messaging (FCM) pengguna ke Odoo.
  Future<void> saveFcmToken(String token) async {
    final uid = session?.userId;
    if (uid == null) {
      print("❌ [FCM Save] Gagal: User belum login (session.userId is null).");
      return;
    }

    print("🚀 [FCM Save] Memulai proses penyimpanan token untuk user ID: $uid");
    print(
        "   - Token: ${token.substring(0, 15)}..."); // Mencetak sebagian token

    try {
      final args = [
        [uid], // List of IDs yang akan diupdate
        {'fcm_token': token}, // Map of values yang akan diupdate
      ];

      print("   - Memanggil Odoo RPC 'write' pada model 'res.users'");
      print("   - Argumen yang dikirim: $args");

      // callKw yang sudah dikonfirmasi berfungsi
      final result = await client.callKw({
        'model': 'res.users',
        'method': 'write',
        'args': args,
        'kwargs': {},
      });

      // Operasi 'write' yang sukses akan mengembalikan 'true'
      if (result == true) {
        print("✅ [FCM Save] SUKSES: Odoo mengonfirmasi token telah tersimpan.");
      } else {
        print(
            "⚠️ [FCM Save] PERINGATAN: Operasi berhasil dieksekusi tapi Odoo tidak mengembalikan 'true'. Result: $result");
      }
    } catch (e) {
      print(
          "🔥 [FCM Save] FATAL ERROR: Terjadi error saat mencoba menyimpan token.");
      print("   - Tipe Error: ${e.runtimeType}");
      print("   - Pesan Error: $e");
    }
  }

  // Mengambil ID karyawan (hr.employee) yang terhubung dengan pengguna Odoo yang sedang login.
  getEmployeeId() async {
    try {
      var res = await get(
        model: "res.users",
        where: [
          ['id', '=', session!.userId],
        ],
        fields: ['employee_id'],
      );

      // Pengecekan untuk memastikan hasil tidak kosong dan ada employee_id
      if (res.isNotEmpty &&
          res[0]["employee_id"] != false &&
          res[0]["employee_id"] != null) {
        employeeId = res[0]["employee_id"][0];
      } else {
        // Handle kasus di mana user tidak terhubung ke data karyawan
        print(
            "User (ID: ${session!.userId}) tidak terhubung dengan data Employee.");
      }
    } catch (e) {
      print("Gagal mendapatkan employee_id: $e");
    }
  }

  // Melakukan proses autentikasi (login) pengguna ke Odoo menggunakan username dan password
  Future<bool> login({
    required String login,
    required String password,
  }) async {
    try {
      session = await client.authenticate(
        _config["database"]!,
        login,
        password,
      );

      if (session == null) {
        print("Login Gagal: Sesi tidak didapatkan (null).");
        return false;
      }

      await getEmployeeId();
      return true;
    } on OdooException catch (e) {
      // Tangkap error spesifik dari Odoo seperti AccessDenied
      print("Login Gagal: OdooException: $e");
      return false;
    } catch (e) {
      // Tangkap semua jenis error lainnya
      print("Login Gagal: Terjadi error tidak terduga: $e");
      return false;
    }
  }

  // Fungsi generik untuk membaca data (search_read) dari model Odoo mana pun.
  Future<List> get({
    required String model,
    List<String>? fields,
    List<List>? where,
    String? orderBy,
    int? limit,
  }) async {
    var res = await client.callKw({
      'model': model,
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': where,
        // 'domain': [
        //   // ['id', '=', session!.userId]
        // ],
        'fields': fields,
        'order': orderBy,
        'limit': limit,
      },
    });
    return res;
  }

  // Fungsi generik untuk membuat record baru (create) di model Odoo mana pun.
  Future create({
    required String model,
    required Map data,
  }) async {
    try {
      print("----");
      print("data:");
      print(data);
      print("----");
      var partnerId = await client.callKw({
        'model': model,
        'method': 'create',
        'args': [data],
        'kwargs': {},
      });
      return partnerId != null;
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  // Fungsi generik untuk memperbarui record yang ada (write) di model Odoo mana pun berdasarkan ID.
  Future update({
    required String model,
    required int id,
    required Map data,
  }) async {
    try {
      var partnerId = await client.callKw({
        'model': model,
        'method': 'write',
        'args': [id, data],
        'kwargs': {},
      });
      return partnerId != null;
    } on Exception {
      return false;
    }
  }

  // Fungsi generik untuk menghapus record (unlink) dari model Odoo mana pun berdasarkan ID.
  Future delete({
    required String model,
    required int id,
  }) async {
    try {
      var partnerId = await client.callKw({
        'model': model,
        'method': 'unlink',
        'args': [id],
        'kwargs': {},
      });
      return partnerId != null;
    } on Exception {
      return false;
    }
  }
}
