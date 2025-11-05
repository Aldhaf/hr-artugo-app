import 'package:geolocator/geolocator.dart';
import 'package:hr_artugo_app/core.dart' hide Get;
import 'dart:async';
import 'package:get/get.dart';
import 'package:hr_artugo_app/service/work_profile_service/work_profile_service.dart';

class AttendanceService {
  final _odooApi = Get.find<OdooApiService>();

  /*
  Mengambil data detail jam kerja harian untuk rentang tanggal tertentu,
  digunakan untuk menampilkan grafik jam kerja di dashboard.
  Memanggil endpoint Odoo 'getDailyWorkedHours'.
  */
  Future<Map<String, dynamic>> getWorkingHoursChartData(
      String startDate, String endDate) async {
    return await _odooApi.getDailyWorkedHours(startDate, endDate);
  }

  /*
  Mengirimkan data check-in ke Odoo beserta data posisi GPS yang valid.
  Memanggil endpoint Odoo 'createAttendanceWithGPS'.
  */
  Future<void> checkInWithGps(Position position) async {
    return await _odooApi.createAttendanceWithGPS(position: position);
  }

  /*
  Memvalidasi izin lokasi, status layanan lokasi, mendeteksi lokasi palsu,
  dan mengambil posisi GPS saat ini dengan akurasi tinggi.
  Melempar Exception jika validasi gagal.
  */
  Future<Position> validateAndGetPosition() async {
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
      throw Exception(
          'Izin lokasi diblokir permanen. Aktifkan dari pengaturan.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 20),
    );

    if (position.isMocked) {
      throw Exception(
          "Lokasi Palsu Terdeteksi. Harap nonaktifkan aplikasi Fake GPS Anda.");
    }

    return position;
  }

  /*  
  Mencari data absensi terakhir yang belum memiliki waktu check-out,
  lalu memperbaruinya dengan waktu saat ini (UTC) sebagai waktu check-out.
  Memanggil endpoint Odoo 'update' pada model 'hr.attendance'. 
  */
  Future<void> checkOut() async {
    var checkinHistory = await getHistory();
    if (checkinHistory.isEmpty) return;

    var openAttendance = checkinHistory.firstWhere(
      (att) => att["check_out"] == false || att["check_out"] == null,
      orElse: () => {},
    );

    if (openAttendance.isEmpty) {
      return;
    }

    var attendanceId = openAttendance["id"];

    return await _odooApi.update(
      model: "hr.attendance",
      id: attendanceId,
      data: {
        'check_out': DateFormat("yyyy-MM-dd HH:mm:ss").format(
          DateTime.now().toUtc(),
        ),
      },
    );
  }

  /*
  Mengambil riwayat absensi (check-in dan check-out) untuk karyawan yang sedang login,
  diurutkan berdasarkan waktu check-in terbaru.
  Memanggil endpoint Odoo 'get' pada model 'hr.attendance'.
  */
  Future<dynamic> getHistory() async {
    return await _odooApi.get(
      model: "hr.attendance",
      where: [
        ['employee_id', '=', _odooApi.employeeId]
      ],
      orderBy: "check_in desc",
    );
  }

  /*
  Mengambil data absensi (check-in, check-out, jam kerja) spesifik untuk hari ini
  bagi karyawan yang sedang login.
  Mengembalikan 'N/A' jika belum ada absensi hari ini.
  */
  Future<Map<String, String>> getTodayAttendance() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    var records = await _odooApi.get(
      model: "hr.attendance",
      where: [
        ['employee_id', '=', _odooApi.employeeId],
        ['check_in', '>=', startOfDay.toUtc().toIso8601String()],
        ['check_in', '<', endOfDay.toUtc().toIso8601String()],
      ],
      fields: ["check_in", "check_out", "worked_hours"],
      orderBy: "check_in desc",
      limit: 1,
    );

    if (records.isEmpty) {
      return {
        "check_in_time": "N/A",
        "check_out_time": "N/A",
        "worked_hours": "00:00:00",
      };
    }

    var todayRecord = records.first;
    String checkInTime = "N/A";
    if (todayRecord["check_in"] != false && todayRecord["check_in"] != null) {
      DateTime checkInUtc =
          DateTime.parse(todayRecord["check_in"] + "Z").toUtc();
      checkInTime = DateFormat("HH:mm:ss").format(checkInUtc.toLocal());
    }

    String checkOutTime = "N/A";
    if (todayRecord["check_out"] != false) {
      DateTime checkOutUtc =
          DateTime.parse(todayRecord["check_out"] + "Z").toUtc();
      checkOutTime = DateFormat("HH:mm:ss").format(checkOutUtc.toLocal());
    }

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

  /*
  Mengambil ringkasan absensi (jumlah hadir, absen, telat) untuk bulan tertentu
  bagi karyawan yang sedang login.
  Membutuhkan `WorkProfileService` untuk logika perhitungan telat.
  */
  Future<Map<String, int>> getMonthSummary(DateTime targetMonth) async {
    DateTime startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
    DateTime endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0);

    final workProfileService = Get.find<WorkProfileService>();
    final workPattern = workProfileService.workProfile?.workPattern;

    var records = await _odooApi.get(
      model: "hr.attendance",
      where: [
        ['employee_id', '=', _odooApi.employeeId],
        ['check_in', '>=', startOfMonth.toIso8601String()],
        ['check_in', '<=', endOfMonth.toIso8601String()],
      ],
      fields: ["check_in"],
    );

    if (records.isEmpty) {
      return {"present": 0, "absent": 0, "late": 0};
    }

    Set<String> uniqueDates = {};
    for (var record in records) {
      DateTime checkInLocal =
          DateTime.parse(record["check_in"] + "Z").toLocal();
      uniqueDates.add(DateFormat("yyyy-MM-dd").format(checkInLocal));
    }
    int presentCount = uniqueDates.length;
    int lateInCount = 0;
    Map<String, List> dailyAttendances = {};
    for (var record in records) {
      DateTime checkInLocal =
          DateTime.parse(record["check_in"] + "Z").toLocal();
      String day = DateFormat("yyyy-MM-dd").format(checkInLocal);
      if (dailyAttendances[day] == null) dailyAttendances[day] = [];
      dailyAttendances[day]!.add(checkInLocal);
    }

    dailyAttendances.forEach((day, attendances) {
      attendances.sort();
      DateTime firstCheckIn = attendances.first;
      if (workPattern != null) {
        int entryHour = workPattern.workFrom.toInt();
        int entryMinute = ((workPattern.workFrom - entryHour) * 60).round();
        if (firstCheckIn.hour > entryHour ||
            (firstCheckIn.hour == entryHour &&
                firstCheckIn.minute > entryMinute)) {
          lateInCount++;
        }
      }
    });

    int workdays = 0;
    for (int i = 1; i <= targetMonth.day; i++) {
      DateTime currentDay = DateTime(targetMonth.year, targetMonth.month, i);
      if (currentDay.weekday >= 1 && currentDay.weekday <= 5) {
        String dayKey = DateFormat("yyyy-MM-dd").format(currentDay);
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

  /*
  Mengambil nama alamat (reverse geocoding) berdasarkan posisi GPS saat ini.
  Menggunakan API eksternal (Nominatim OpenStreetMap) via Dio.
  Menangani error jika GPS mati, izin ditolak, timeout, atau koneksi gagal.
  */
  Future<String> getCurrentAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Layanan lokasi mati. Mohon aktifkan.";
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Izin lokasi dibutuhkan untuk melanjutkan.";
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return "Izin lokasi diblokir. Aktifkan dari pengaturan HP.";
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 15),
      );
      var response = await Dio()
          .get(
            "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}",
            options: Options(
              headers: {
                "User-Agent": "ArtuGo/1.0 (HR Odoo Project; aldhaf@artugo.id)",
              },
            ),
          )
          .timeout(const Duration(seconds: 15));
      Map obj = response.data;
      return obj["display_name"] ?? "Alamat tidak ditemukan";
    } on TimeoutException {
      return "Gagal mendapat sinyal lokasi. Coba lagi di tempat terbuka.";
    } on DioException {
      return "Gagal terhubung ke server peta.";
    } catch (e) {
  
      return "Terjadi kesalahan tidak terduga.";
    }
  }
}
