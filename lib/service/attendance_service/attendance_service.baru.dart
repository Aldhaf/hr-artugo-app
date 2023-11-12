// import 'package:intl/intl.dart';

// import '../../shared/util/odoo_api/odoo_api.dart';

// class AttendanceService {
//   Future checkin() async {
//     var fdate = DateFormat("yyyy-MM-dd kk:mm:ss").format(
//       DateTime.now(),
//     );
//     var res = await OdooApi.create(
//       model: "hr.attendance",
//       data: {
//         'employee_id': OdooApi.employeeId,
//         'check_in': fdate,
//       },
//     );
//     print(OdooApi.employeeId);
//     print(fdate);
//     print(OdooApi.employeeId);
//     print(res);
//   }

//   Future checkout() async {
//     int attendanceId = -1;

//     var attendanceResults = await OdooApi.get(
//       model: "hr.attendance",
//       where: [
//         ["employee_id", "=", OdooApi.employeeId],
//         ["check_out", "=", false],
//       ],
//     );
//     if (attendanceResults.isEmpty) {
//       print("Kamu belum checkin");
//       return;
//     }
//     attendanceId = attendanceResults.first["id"];
//     print(attendanceId);
//     print(attendanceResults);

//     var fdate = DateFormat("yyyy-MM-dd kk:mm:ss").format(
//       DateTime.now(),
//     );
//     var res = await OdooApi.update(
//       model: "hr.attendance",
//       id: attendanceId,
//       data: {
//         'check_out': fdate,
//       },
//     );
//     print(OdooApi.employeeId);
//     print(fdate);
//     print(OdooApi.employeeId);
//     print(res);
//   }
// }
