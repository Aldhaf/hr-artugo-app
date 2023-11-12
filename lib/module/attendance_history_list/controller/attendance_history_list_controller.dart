import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class AttendanceHistoryListController extends State<AttendanceHistoryListView> {
  static late AttendanceHistoryListController instance;
  late AttendanceHistoryListView view;

  @override
  void initState() {
    instance = this;
    getAttendanceList();
    super.initState();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => widget.build(context, this);

  List items = [];
  getAttendanceList() async {
    var response = await AttendanceService.getHistory();
    print(response);
    items = response;
    setState(() {});
  }
}
