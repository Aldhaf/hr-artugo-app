import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class AttendanceHistoryListView extends StatefulWidget {
  const AttendanceHistoryListView({Key? key}) : super(key: key);

  Widget build(context, AttendanceHistoryListController controller) {
    controller.view = this;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AttendanceHistoryList"),
        actions: const [],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  var item = controller.items[index];
                  var date = item["check_in"].toString().dMMMy;
                  var checkIn = item["check_in"].toString().kkmmss;
                  var checkOut = item["check_out"].toString().kkmmss;
                  double hour = item["worked_hours"];
                  int jamInt = hour.toInt();
                  double menit = (hour - jamInt) * 60;
                  String wh =
                      "${jamInt.floor().toString().padLeft(2, "0")}:${menit.floor().toString().padLeft(2, "0")}";

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Check In:\n$checkIn"),
                                    const SizedBox(
                                      height: 12.0,
                                    ),
                                    Text("Check Out:\n$checkOut"),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Working hours",
                                    style: TextStyle(
                                      fontSize: 10.0,
                                    ),
                                  ),
                                  Text(wh),
                                ],
                              )
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () => Get.to(
                                  LocationDetailView(
                                    latitude: item["check_in_latitude"],
                                    longitude: item["check_in_longitude"],
                                  ),
                                ),
                                child: const Text(
                                  "Check In Location",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 12.0,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Get.to(
                                  LocationDetailView(
                                    latitude: item["check_out_latitude"],
                                    longitude: item["check_out_longitude"],
                                  ),
                                ),
                                child: const Text(
                                  "Check Out Location",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  return Card(
                    child: ListTile(
                      title: Text(date),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Check In:\n$checkIn"),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text("Check Out:\n$checkOut"),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Working hours",
                            style: TextStyle(
                              fontSize: 10.0,
                            ),
                          ),
                          Text(wh),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<AttendanceHistoryListView> createState() =>
      AttendanceHistoryListController();
}
