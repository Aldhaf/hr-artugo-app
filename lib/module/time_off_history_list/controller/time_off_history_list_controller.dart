import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class TimeOffHistoryListController extends State<TimeOffHistoryListView> {
  static late TimeOffHistoryListController instance;
  late TimeOffHistoryListView view;

  @override
  void initState() {
    instance = this;
    getTimeOffHistories();
    super.initState();
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => widget.build(context, this);

  List items = [];
  getTimeOffHistories() async {
    var response = await TimeOffService().get();
    items = response;
    setState(() {});
  }
}
