import 'package:flutter/material.dart';
import 'package:hyper_ui/service/attendance_service/attendance_service.dart';
import '../view/dashboard_view.dart';

class DashboardController extends State<DashboardView> {
  static late DashboardController instance;
  late DashboardView view;

  @override
  void initState() {
    instance = this;
    super.initState();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => widget.build(context, this);

  doCheckIn() async {
    AttendanceService().checkin();
  }

  doCheckOut() async {
    AttendanceService().checkout();
  }
}
