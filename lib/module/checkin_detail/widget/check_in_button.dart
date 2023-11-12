// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class CheckInButton extends StatefulWidget {
  const CheckInButton({Key? key}) : super(key: key);

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  bool? isCheckedIn;
  String time = "";
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    isCheckedIn = await AttendanceService.isCheckedInToday();
    setState(() {});

    var histories = await AttendanceService.getHistory();
    if (histories.length > 0) {
      DateTime date = DateTime.parse(histories.first["check_in"]);
      time = DateFormat("kk:mm:ss").format(date);
      setState(() {});
    }

    await CheckOutButtonState.instance.loadData();
  }

  doCheckIn() async {
    showLoading();
    await AttendanceService.checkin();
    await loadData();
    hideLoading();

    AttendanceHistoryListController.instance.getAttendanceList();
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckedIn == null) {
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

    if (isCheckedIn == true) {
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
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () => doCheckIn(),
          child: const Text("Check In"),
        ),
      ),
    );
  }
}
