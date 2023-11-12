import 'package:odoo_rpc/odoo_rpc.dart';

import '../../../env.dart';

class OdooApi {
  static OdooClient client = OdooClient(config['host']!);
  static OdooSession? session;
  static int? employeeId;
  static login({
    required String username,
    required String password,
  }) async {
    try {
      session = await client.authenticate(
        config["database"]!,
        username,
        password,
      );

      if (session == null) return false;
      await getEmployeeId();
      return true;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  static getEmployeeId() async {
    var res = await OdooApi.get(model: "res.users", where: [
      ['id', '=', OdooApi.session!.userId],
    ], fields: [
      'employee_id',
    ]);

    employeeId = res[0]["employee_id"][0];
  }

  static Future<List> get({
    required String model,
    List<String>? fields,
    List<List>? where,
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
      },
    });
    return res;
  }

  static Future create({
    required String model,
    required Map data,
  }) async {
    try {
      var partnerId = await client.callKw({
        'model': model,
        'method': 'create',
        'args': [data],
        'kwargs': {},
      });
      return partnerId != null;
    } on Exception {
      return false;
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
