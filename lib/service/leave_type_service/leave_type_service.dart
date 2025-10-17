import 'package:get/get.dart';
import 'package:hr_artugo_app/shared/util/odoo_api/odoo_api.dart';

class LeaveTypeService {
  Future get() async {
    final _odooApi = Get.find<OdooApiService>();
    
    return await _odooApi.get(
      model: "hr.leave.type",
      where: [
        // [
        //   'employee_id',
        //   '=',
        //   _odooApi.employeeId,
        // ]
      ],
    );
  }
}
