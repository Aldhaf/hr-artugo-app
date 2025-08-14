// lib/module/time_off_history_list/view/time_off_history_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class TimeOffHistoryListView extends StatelessWidget {
  const TimeOffHistoryListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimeOffHistoryListController());

    return Scaffold(
      appBar: AppBar(
        // 1. Memposisikan judul di tengah
        centerTitle: true,
        title: const Text("Time Off"),
        elevation: 0.6, // Menambahkan sedikit bayangan agar terlihat
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Get.to(const TimeOffFormView());
          controller.getTimeOffHistories();
        },
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return const Center(child: Text("No time off history."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            var item = controller.items[index];

            var dateFrom = item["date_from"].toString().dMMMy;
            var dateTo = item["date_to"].toString().dMMMy;
            String duration = item["duration_display"] ?? "-";
            String name = item["private_name"] ?? "-";
            String state = item["state"] ?? "draft"; // Mengambil status cuti

            // Menentukan warna berdasarkan status
            Color statusColor;
            switch (state) {
              case 'validate':
                statusColor = Colors.green;
                break;
              case 'refuse':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange; // Status 'to approve' atau lainnya
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Garis aksen dengan warna status
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris atas berisi tanggal dan status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$dateFrom - $dateTo",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    state.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24.0),
                            // Baris bawah berisi durasi dan deskripsi
                            Text(
                              "Duration: $duration",
                              style: const TextStyle(
                                  fontSize: 14.0, color: Colors.black54),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Description: $name",
                              style: const TextStyle(
                                  fontSize: 14.0, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
