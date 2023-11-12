// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class CheckOutButton extends StatefulWidget {
  const CheckOutButton({Key? key}) : super(key: key);

  @override
  State<CheckOutButton> createState() => CheckOutButtonState();
}

class CheckOutButtonState extends State<CheckOutButton> {
  static late CheckOutButtonState instance;

  bool? isCheckedOut;
  bool? isCheckedIn;
  String time = "";
  @override
  void initState() {
    loadData();
    instance = this;
    super.initState();
  }

  loadData() async {
    isCheckedIn = await AttendanceService.isCheckedInToday();
    isCheckedOut = await AttendanceService.isCheckedOutToday();
    setState(() {});

    var histories = await AttendanceService.getHistory();
    if (histories.length > 0) {
      if (histories.first["check_out"] == false) return;
      DateTime date = DateTime.parse(histories.first["check_out"]);
      time = DateFormat("kk:mm:ss").format(date);
      setState(() {});
    }
  }

  doCheckOut() async {
    showLoading();
    await AttendanceService.checkOut();
    await loadData();
    hideLoading();

    AttendanceHistoryListController.instance.getAttendanceList();
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckedOut == null) {
      return Expanded(
        child: SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            onPressed: () {},
            child: const Text("Loading..."),
          ),
        ),
      );
    }

    if (isCheckedOut == true) {
      return Expanded(
        child: SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            onPressed: () {},
            child: Text(
              time,
              style: TextStyle(
                color: Colors.blueGrey[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (isCheckedIn == false) {
      return Expanded(
        child: SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            onPressed: () {},
            child: const Text("Check Out"),
          ),
        ),
      );
    }
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => doCheckOut(),
          child: const Text("Check Out"),
        ),
      ),
    );
  }
}
