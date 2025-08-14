import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';
import 'package:intl/intl.dart';

class TimeOffService {
  Future get() async {
    return await OdooApi.get(
      model: "hr.leave",
      where: [
        [
          'employee_id',
          '=',
          OdooApi.employeeId,
        ]
      ],
    );
  }

  Future create({
    required int leaveTypeId,
    required DateTime dateFrom,
    required DateTime dateTo,
    required String name,
  }) async {
    try {
      await OdooApi.create(
        model: "hr.leave",
        data: {
          // 'employee_id': AuthService.session.id,
          'employee_id': OdooApi.employeeId,
          // 'date_from': DateFormat("yyyy-MM-dd kk:mm:ss").format(dateFrom),
          // 'date_to': DateFormat("yyyy-MM-dd kk:mm:ss").format(dateTo),
          'date_from': DateFormat("yyyy-MM-dd 00:00:00").format(dateFrom),
          'date_to': DateFormat("yyyy-MM-dd 00:00:00").format(dateTo),
          // 'duration': duration, //
          'name': name, //
          'holiday_status_id': leaveTypeId,
        },
      );
      return true;
    } on Exception {
      return false;
    }
  }
}
/*
http://103.49.239.49:8069/jw_expense/delete?domain=[['id','=',13]]&model='hr.expense'
*/
