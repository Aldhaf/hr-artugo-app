import 'package:odoo_rpc/odoo_rpc.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../env.dart';

class OdooApi {
  static OdooClient client = OdooClient(config['host']!);
  static OdooSession? session;
  static int? employeeId;

  // Fungsi baru untuk upload absensi dengan foto menggunakan Dio
  static Future<void> createAttendanceWithPhoto({
    required Position position,
    required File photo,
  }) async {
    final url = "${config['host']!}/api/hr_attendance/check_in";

    // --- PERBAIKAN DIMULAI DI SINI ---

    // 1. Ambil ID sesi (dalam bentuk String) dari objek sesi yang kita simpan saat login.
    final String? sessionId = OdooApi.session?.id; // <-- GANTI DENGAN BARIS INI

    // 2. Tambahkan print untuk debugging.
    print("Mencoba upload dengan Session ID: $sessionId");

    // 3. Lakukan pengecekan yang lebih ketat
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("Sesi tidak ditemukan. Silakan coba login ulang.");
    }

    // --- AKHIR PERBAIKAN ---

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

      // Set header Cookie dengan session ID yang sudah kita verifikasi
      dio.options.headers['Cookie'] = 'session_id=$sessionId';

      print("Mengirim data absensi ke: $url");
      await dio.post(url, data: formData);
      print("Data absensi berhasil dikirim.");
    } on DioException catch (e) {
      print("--- Dio Error on Upload ---");
      print("Error: ${e.message}");
      print("Response: ${e.response?.data}"); // Cetak juga respons dari server
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

  static String? getUserImageUrl(int uid) {
    // Odoo biasanya menyajikan gambar melalui URL ini
    // Ganti 'config['host']!' dengan URL dasar server Anda jika perlu
    return "${config['host']!}/web/image?model=res.users&id=$uid&field=image_1920";
  }

  static Future<bool> deleteNotification(int id) async {
    try {
      final response = await client.callKw({
        'model': 'hr.notification',
        'method': 'unlink',
        'args': [
          [id]
        ], // 'unlink' menerima list of IDs
        'kwargs': {},
      });
      print("Notifikasi ID $id berhasil dihapus dari server.");
      return response as bool? ?? false;
    } catch (e) {
      print("Gagal menghapus notifikasi ID $id: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getTimeOffDetail(int id) async {
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
        // Tambahkan print di sini untuk debugging
        print("Data cuti yang diterima dari Odoo: ${response[0]}");
        return response[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Gagal mengambil detail Time Off: $e");
      return null;
    }
  }

  // Di dalam class OdooApi
  static Future<void> markNotificationsAsRead(List<int> ids) async {
    if (ids.isEmpty) return;
    try {
      // --- PERBAIKAN FINAL: Gunakan 'callKw' yang sudah terbukti berfungsi ---
      await client.callKw({
        'model': 'hr.notification',
        'method': 'write', // Tentukan method 'write' di sini
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

  /// Mengambil daftar riwayat notifikasi untuk user yang sedang login.
  static Future<List<dynamic>> fetchNotifications() async {
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

  /// Menyimpan FCM Token ke record user yang sedang login di Odoo.
  static Future<void> saveFcmToken(String token) async {
    final uid = session?.userId;
    if (uid == null) {
      print("❌ [FCM Save] Gagal: User belum login (session.userId is null).");
      return;
    }

    print("🚀 [FCM Save] Memulai proses penyimpanan token untuk user ID: $uid");
    print("   - Token: ${token.substring(0, 15)}..."); // Cetak sebagian token

    try {
      // Siapkan argumen dengan hati-hati
      final args = [
        [uid], // List of IDs yang akan diupdate
        {'fcm_token': token}, // Map of values yang akan diupdate
      ];

      print("   - Memanggil Odoo RPC 'write' pada model 'res.users'");
      print("   - Argumen yang dikirim: $args");

      // Gunakan callKw yang sudah Anda konfirmasi berfungsi
      final result = await OdooApi.client.callKw({
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
      // Tangkap dan cetak semua jenis error
      print(
          "🔥 [FCM Save] FATAL ERROR: Terjadi error saat mencoba menyimpan token.");
      print("   - Tipe Error: ${e.runtimeType}");
      print("   - Pesan Error: $e");
    }
  }

  static getEmployeeId() async {
    try {
      var res = await OdooApi.get(
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
        // Odoo mengembalikan relasi dalam format [id, nama]
        // Kita hanya butuh id-nya, yaitu item pertama.
        employeeId = res[0]["employee_id"][0];
      } else {
        // Handle kasus di mana user tidak terhubung ke data karyawan
        print(
            "User (ID: ${session!.userId}) tidak terhubung dengan data Employee.");
      }
    } catch (e) {
      print("Gagal mendapatkan employee_id: $e");
      // Anda bisa memutuskan untuk throw error lagi atau tidak, tergantung kebutuhan
    }
  }

  static Future<bool> login({
    required String login,
    required String password,
  }) async {
    try {
      session = await client.authenticate(
        config["database"]!,
        login,
        password,
      );

      if (session == null) {
        print("Login Gagal: Sesi tidak didapatkan (null).");
        return false;
      }

      await getEmployeeId();
      return true; // HANYA baris ini yang bisa mengembalikan true
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

  static Future<List> get({
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

  static Future create({
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

  static Future update({
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

  static Future delete({
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
