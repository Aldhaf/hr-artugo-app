import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';

class TimeOffHistoryListView extends StatefulWidget {
  const TimeOffHistoryListView({Key? key}) : super(key: key);

  Widget build(context, TimeOffHistoryListController controller) {
    controller.view = this;

    return Scaffold(
      appBar: AppBar(
        title: const Text("TimeOffHistoryList"),
        actions: const [],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Get.to(TimeOffFormView());
          controller.getTimeOffHistories();
        },
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  var item = controller.items[index];
                  var dateFrom = item["date_from"].toString().dMMMy;
                  var dateTo = item["date_to"].toString().dMMMy;
                  String duration = item["duration_display"] ?? "-";
                  String name = item["private_name"] ?? "-";

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${dateFrom} - ${dateTo}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          Text("Duration:\n$duration"),
                          Divider(),
                          Text("Description:\n$name"),
                          const Divider(),
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
  State<TimeOffHistoryListView> createState() => TimeOffHistoryListController();
}
