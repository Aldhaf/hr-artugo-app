import 'package:geolocator/geolocator.dart';
import 'package:hyper_ui/core.dart';

class AttendanceService {
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

  static checkin() async {
    Position position = await getLocation();

    return await OdooApi.create(
      model: "hr.attendance",
      data: {
        // 'employee_id': AuthService.session.id,
        'employee_id': OdooApi.employeeId,
        'check_in': DateFormat("yyyy-MM-dd kk:mm:ss").format(
          DateTime.now(),
        ),
        // 'check_in': DateTime(2023, 2, 25).toIso8601String(),
        // 'check_in': "2023-02-26 07:00:00",
        //TODO: field perlu ditambahkan
        'check_in_latitude': position.latitude,
        'check_in_longitude': position.longitude,
      },
    );
  }

  static checkOut() async {
    var checkinHistory = await AttendanceService.getHistory();
    print(checkinHistory);
    var attendanceId = checkinHistory.first["id"];
    Position position = await getLocation();

    return await OdooApi.update(
      model: "hr.attendance",
      id: attendanceId,
      data: {
        // 'employee_id': AuthService.session.id,
        'check_out': DateFormat("yyyy-MM-dd kk:mm:ss").format(
          DateTime.now(),
        ),
        // 'check_out': "2023-02-27 11:00:00",
        // 'check_out': DateFormat("yyyy-MM-dd kk:mm:ss").format(DateTime.now()),
        // 'check_in': DateTime(2023, 2, 25).toIso8601String(),
        // 'check_in': "2023-02-26 07:00:00",
        //TODO: field perlu ditambahkan
        'check_out_latitude': position.latitude,
        'check_out_longitude': position.longitude,
      },
    );
  }

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
    );
  }

  static Future<bool> isCheckedInToday() async {
    var history = await AttendanceService.getHistory();

    print("----");
    print(history);

    List list = history.where((i) {
      var checkInDate =
          DateFormat("d MMM y").format(DateTime.parse(i["check_in"]));
      var today = DateFormat("d MMM y").format(DateTime.now());

      print("checkInDate: $checkInDate");
      print("today: $today");
      return checkInDate == DateFormat("d MMM y").format(DateTime.now());
    }).toList();

    if (list.isEmpty) {
      return false;
    }

    if (history.length == 0) {
      return false;
    }

    if (history.first["check_in"] == null) {
      return false;
    }

    return true;
  }

  static Future<bool> isCheckedOutToday() async {
    var history = await AttendanceService.getHistory();
    if (history.length == 0) {
      return false;
    }

    if (history.first["check_in"] == null) {
      return false;
    }

    List list = history.where((i) {
      var checkInDate =
          DateFormat("d MMM y").format(DateTime.parse(i["check_in"]));
      var today = DateFormat("d MMM y").format(DateTime.now());

      print("checkInDate: $checkInDate");
      print("today: $today");
      return checkInDate == DateFormat("d MMM y").format(DateTime.now());
    }).toList();
    print(list.isEmpty);
    print("----");

    if (list.isEmpty) {
      return false;
    }

    if (history.first["check_out"] == null ||
        history.first["check_out"] == false) {
      return false;
    }

    return true;
  }
}
