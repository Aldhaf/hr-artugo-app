import 'package:geolocator/geolocator.dart';
import 'package:hyper_ui/core.dart';
import 'dart:async';
import 'dart:io'; // Pastikan import ini ada
import 'package:image_picker/image_picker.dart'; // Pastikan import ini ada

class AttendanceService {
  // Fungsi ini akan menjadi metode check-in yang baru dan aman.
  Future<void> executeSecureCheckIn() async {
    // Langkah 1: Validasi dan Ambil Posisi GPS
    Position position;
    try {
      // Mengambil posisi dengan penanganan izin dan status layanan lokasi
      position = await _validateAndGetPosition();
      // Cek apakah mock location aktif
      if (position.isMocked) {
        throw Exception("Lokasi Palsu Terdeteksi. Harap nonaktifkan fitur 'Mock Location' di Pengaturan Developer.");
      }
    } catch (e) {
      // Lempar kembali error agar bisa ditangkap oleh UI Controller
      rethrow;
    }

    // Langkah 2: Wajibkan Pengguna Mengambil Foto via Kamera
    final XFile? photoFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Kompres ukuran file agar upload lebih efisien
      maxWidth: 1080, // Ubah ukuran lebar gambar maksimal menjadi 1080 piksel
      preferredCameraDevice: CameraDevice.front, // Utamakan kamera depan untuk selfie
    );

    // Jika pengguna membatalkan pengambilan foto, gagalkan proses
    if (photoFile == null) {
      throw Exception("Proses dibatalkan. Foto bukti wajib diambil.");
    }

    // Langkah 3: Kirim data (Posisi + Foto) ke Odoo
    // Kita akan panggil fungsi baru di OdooApi yang bisa meng-handle upload file
    await OdooApi.createAttendanceWithPhoto(
      position: position,
      photo: File(photoFile.path),
    );
  }

  // Helper function privat untuk mengambil posisi (bisa Anda ambil dari logika getCurrentAddress)
  Future<Position> _validateAndGetPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi mati. Mohon aktifkan.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi diblokir permanen. Aktifkan dari pengaturan.');
    }

    // Ambil posisi saat ini
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 20),
    );
  }

  // Fungsi getLocation() tidak diubah, mungkin masih berguna untuk fitur lain.
  static getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  // --- PERUBAHAN DIMULAI DI SINI ---
  static checkin() async {
    return await OdooApi.create(
      model: "hr.attendance",
      data: {
        'employee_id': OdooApi.employeeId,
        'check_in': DateFormat("yyyy-MM-dd HH:mm:ss").format(
          DateTime.now().toUtc(), // <-- UBAH DI SINI
        ),
      },
    );
  }

  static checkOut() async {
    var checkinHistory = await AttendanceService.getHistory();
    if (checkinHistory.isEmpty) return;

    // Cari record pertama yang belum memiliki check_out
    var openAttendance = checkinHistory.firstWhere(
      (att) => att["check_out"] == false || att["check_out"] == null,
      orElse: () => {}, // Kembalikan map kosong jika tidak ditemukan
    );

    // Jika tidak ada absensi yang terbuka, jangan lakukan apa-apa
    if (openAttendance.isEmpty) {
      print("Tidak ada sesi absensi yang terbuka untuk di-checkout.");
      return;
    }

    var attendanceId = openAttendance["id"];

    return await OdooApi.update(
      model: "hr.attendance",
      id: attendanceId,
      data: {
        'check_out': DateFormat("yyyy-MM-dd HH:mm:ss").format(
          DateTime.now().toUtc(),
        ),
      },
    );
  }
  // --- PERUBAHAN SELESAI DI SINI ---

  static getHistory() async {
    return await OdooApi.get(
      model: "hr.attendance",
      where: [
        [
          'employee_id',
          '=',
          OdooApi.employeeId,
        ]
      ],
      // Tambahkan order by agar data terbaru ada di paling atas
      orderBy: "check_in desc",
    );
  }

  static Future<bool> isCheckedInToday() async {
    var history = await AttendanceService.getHistory();
    if (history.isEmpty) return false;

    var today = DateFormat("d MMM y").format(DateTime.now());

    List list = history.where((i) {
      // Konversi waktu check_in dari UTC ke Lokal sebelum membandingkan
      DateTime checkInLocalTime =
          DateTime.parse(i["check_in"].toString() + "Z").toLocal();
      var checkInDate = DateFormat("d MMM y").format(checkInLocalTime);
      return checkInDate == today;
    }).toList();

    return list.isNotEmpty;
  }

  static Future<bool> isCheckedOutToday() async {
    var history = await AttendanceService.getHistory();
    if (history.isEmpty) {
      return false;
    }

    var today = DateFormat("d MMM y").format(DateTime.now());

    var lastAttendanceToday = history.firstWhere(
      (i) {
        // Konversi waktu check_in dari UTC ke Lokal sebelum membandingkan
        DateTime checkInLocalTime =
            DateTime.parse(i["check_in"].toString() + "Z").toLocal();
        var checkInDate = DateFormat("d MMM y").format(checkInLocalTime);
        return checkInDate == today;
      },
      orElse: () => {},
    );

    if (lastAttendanceToday.isEmpty) {
      return false;
    }

    if (lastAttendanceToday["check_out"] == null ||
        lastAttendanceToday["check_out"] == false) {
      return false;
    }

    return true;
  }

  static Future<Map<String, String>> getTodayAttendance() async {
    // Tentukan awal dan akhir hari ini
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    // Cari data absensi hari ini untuk user yang sedang login
    var records = await OdooApi.get(
      model: "hr.attendance",
      where: [
        ['employee_id', '=', OdooApi.employeeId],
        ['check_in', '>=', startOfDay.toUtc().toIso8601String()],
        ['check_in', '<', endOfDay.toUtc().toIso8601String()],
      ],
      fields: ["check_in", "check_out", "worked_hours"],
      orderBy: "check_in desc",
      limit: 1, // Ambil hanya 1 data terbaru
    );

    // Jika tidak ada data, kembalikan nilai default
    if (records.isEmpty) {
      return {
        "check_in_time": "N/A",
        "check_out_time": "N/A",
        "worked_hours": "00:00:00",
      };
    }

    var todayRecord = records.first;

    // Format waktu check_in
    String checkInTime = "N/A";
    if (todayRecord["check_in"] != false && todayRecord["check_in"] != null) {
      DateTime checkInUtc =
          DateTime.parse(todayRecord["check_in"] + "Z").toUtc();
      checkInTime = DateFormat("HH:mm:ss").format(checkInUtc.toLocal());
    }

    // Format waktu check_out (jika ada)
    String checkOutTime = "N/A";
    if (todayRecord["check_out"] != false) {
      DateTime checkOutUtc =
          DateTime.parse(todayRecord["check_out"] + "Z").toUtc();
      checkOutTime = DateFormat("HH:mm:ss").format(checkOutUtc.toLocal());
    }

    // Format jam kerja
    double hours = todayRecord["worked_hours"] ?? 0.0;
    int jam = hours.toInt();
    double menit = (hours - jam) * 60;
    String workedHours =
        "${jam.toString().padLeft(2, "0")}:${menit.floor().toString().padLeft(2, "0")}:00";

    return {
      "check_in_time": checkInTime,
      "check_out_time": checkOutTime,
      "worked_hours": workedHours,
    };
  }

  // Letakkan fungsi ini juga di dalam class AttendanceService
  static Future<Map<String, int>> getMonthSummary() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    var records = await OdooApi.get(
      model: "hr.attendance",
      where: [
        ['employee_id', '=', OdooApi.employeeId],
        ['check_in', '>=', startOfMonth.toIso8601String()],
        ['check_in', '<=', endOfMonth.toIso8601String()],
      ],
      fields: ["check_in"],
    );

    if (records.isEmpty) {
      return {"present": 0, "absent": 0, "late": 0};
    }

    // 1. Hitung hari hadir berdasarkan tanggal unik
    Set<String> uniqueDates = {};
    for (var record in records) {
      DateTime checkInLocal =
          DateTime.parse(record["check_in"] + "Z").toLocal();
      uniqueDates.add(DateFormat("yyyy-MM-dd").format(checkInLocal));
    }
    int presentCount = uniqueDates.length;

    // 2. Hitung keterlambatan berdasarkan check-in pertama setiap hari
    int lateInCount = 0;
    // Kelompokkan absensi berdasarkan hari
    Map<String, List> dailyAttendances = {};
    for (var record in records) {
      DateTime checkInLocal =
          DateTime.parse(record["check_in"] + "Z").toLocal();
      String day = DateFormat("yyyy-MM-dd").format(checkInLocal);
      if (dailyAttendances[day] == null) dailyAttendances[day] = [];
      dailyAttendances[day]!.add(checkInLocal);
    }

    dailyAttendances.forEach((day, attendances) {
      attendances.sort(); // Urutkan untuk menemukan check-in pertama
      DateTime firstCheckIn = attendances.first;
      // Asumsi jam masuk adalah 08:15
      if (firstCheckIn.hour > 8 ||
          (firstCheckIn.hour == 8 && firstCheckIn.minute > 15)) {
        lateInCount++;
      }
    });

    // 3. Hitung hari absen
    int workdays = 0;
    // Hitung hari kerja dari awal bulan sampai hari ini
    for (int i = 1; i <= now.day; i++) {
      DateTime currentDay = DateTime(now.year, now.month, i);
      // Cek jika hari adalah Senin - Jumat
      if (currentDay.weekday >= 1 && currentDay.weekday <= 5) {
        String dayKey = DateFormat("yyyy-MM-dd").format(currentDay);
        // Cek apakah karyawan hadir pada hari kerja tersebut
        if (!uniqueDates.contains(dayKey)) {
          workdays++;
        }
      }
    }
    int absentCount = workdays;

    return {
      "present": presentCount,
      "absent": absentCount,
      "late": lateInCount,
    };
  }

  static Future<String> getCurrentAddress() async {
    // --- 1. Cek Izin dengan Pesan Error Spesifik ---
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Pesan jika GPS/Layanan Lokasi mati
      return "Layanan lokasi mati. Mohon aktifkan.";
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Pesan jika pengguna menolak izin
        return "Izin lokasi dibutuhkan untuk melanjutkan.";
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Pesan jika izin ditolak permanen
      return "Izin lokasi diblokir. Aktifkan dari pengaturan HP.";
    }

    // --- 2. Ambil Posisi dan Panggil API dengan Timeout ---
    try {
      // Batasi waktu pencarian GPS menjadi 15 detik
      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );

      // Batasi waktu panggilan API menjadi 15 detik
      var response = await Dio()
          .get(
            "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}",
            options: Options(
              headers: {
                "User-Agent": "Arttend/1.0 (HR Odoo Project; aldhaf@artugo.id)",
              },
            ),
          )
          .timeout(const Duration(seconds: 15));

      Map obj = response.data;
      return obj["display_name"] ?? "Alamat tidak ditemukan";
    } on TimeoutException {
      // Pesan jika waktu habis (sinyal GPS lemah atau internet lambat)
      return "Gagal mendapat sinyal lokasi. Coba lagi di tempat terbuka.";
    } on DioException {
      // Pesan jika ada masalah koneksi ke server OpenStreetMap
      return "Gagal terhubung ke server peta.";
    } catch (e) {
      // Pesan untuk error lainnya yang tidak terduga
      print("Error getting address: $e");
      return "Terjadi kesalahan tidak terduga.";
    }
  }
}
