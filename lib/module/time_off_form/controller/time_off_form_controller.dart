import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';
import 'package:hyper_ui/service/leave_type_service/leave_type_service.dart';
import '../view/time_off_form_view.dart';

class TimeOffFormController extends State<TimeOffFormView> {
  static late TimeOffFormController instance;
  late TimeOffFormView view;

  @override
  void initState() {
    instance = this;
    getLeaveTypes();
    super.initState();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => widget.build(context, this);

  int? leaveTypeId;
  DateTime? dateFrom;
  DateTime? dateTo;
  String? name;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  doSave() async {
    bool isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    bool isSuccess = await TimeOffService().create(
      leaveTypeId: leaveTypeId!,
      name: name!,
      dateFrom: dateFrom!,
      dateTo: dateTo!,
    );
    if (!isSuccess) {
      snackbarDanger(
          message: "Tidak bisa membuat cuti, mungkin jatah cuti habis!");
      return;
    }
    Get.back();
  }

  List leaveTypes = [];
  getLeaveTypes() async {
    leaveTypes = await LeaveTypeService().get();
    setState(() {});
  }
}
