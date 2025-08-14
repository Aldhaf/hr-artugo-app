import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';

class LeaveTypeService {
  Future get() async {
    return await OdooApi.get(
      model: "hr.leave.type",
      where: [
        // [
        //   'employee_id',
        //   '=',
        //   OdooApi.employeeId,
        // ]
      ],
    );
  }
}
