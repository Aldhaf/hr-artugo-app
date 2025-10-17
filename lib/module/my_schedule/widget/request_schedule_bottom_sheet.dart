import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/module/my_schedule/controller/my_schedule_controller.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/work_pattern_model.dart';

class RequestScheduleBottomSheet extends StatefulWidget {
  const RequestScheduleBottomSheet({super.key});

  @override
  State<RequestScheduleBottomSheet> createState() =>
      _RequestScheduleBottomSheetState();
}

class _RequestScheduleBottomSheetState
    extends State<RequestScheduleBottomSheet> {
  final MyScheduleController controller = Get.find();
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    // Saat widget pertama kali dibuat, langsung ambil data tanggal terisi untuk bulan ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBookedDatesForMonth(DateTime.now());
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
    });

    if (start != null) {
      // Jika 'end' kosong, anggap 'end' sama dengan 'start' (untuk 1 hari)
      final DateTime finalEndDate = end ?? start;

      final days = List<DateTime>.generate(
        finalEndDate.difference(start).inDays + 1,
        (i) => start.add(Duration(days: i)),
      );
      controller.addDateRangeToRequest(days);
    } else {
      // Jika 'start' kosong (pilihan dibatalkan), baru kosongkan daftar
      controller.selectedRequests.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Pilih Rentang Tanggal",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TableCalendar(
            firstDay: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: _focusedDay,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: _rangeSelectionMode,
            onRangeSelected: _onRangeSelected,
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              controller.fetchBookedDatesForMonth(focusedDay);
            },

            // Properti untuk menonaktifkan tanggal
            enabledDayPredicate: (day) {
              // 'day' adalah setiap tanggal yang akan digambar oleh kalender
              // Kita periksa apakah tanggal ini ada di dalam daftar 'bookedDates'
              return !controller.bookedDates.any((bookedDate) =>
                  bookedDate.year == day.year &&
                  bookedDate.month == day.month &&
                  bookedDate.day == day.day);
            },

            // Beri gaya visual berbeda untuk tanggal yang nonaktif
            calendarStyle: CalendarStyle(
              disabledTextStyle: TextStyle(
                color: Colors.grey.shade400,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.selectedRequests.isEmpty) {
              return const SizedBox.shrink();
            }
            return Expanded(
              child: ListView.builder(
                itemCount: controller.selectedRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.selectedRequests[index];
                  return ListTile(
                    title: Text(DateFormat('EEEE, d MMM').format(request.date)),
                    trailing: Obx(() => _buildShiftDropdown(
                        index, controller.availablePatterns)),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.submitScheduleRequest(),
            child: const Text("Kirim Pengajuan"),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
          )
        ],
      ),
    );
  }

  Widget _buildShiftDropdown(int index, List<WorkPattern> patterns) {
    // Beri batasan lebar pada DropdownButton
    return SizedBox(
      width: 150, // Atur lebar yang sesuai, misalnya 150
      child: DropdownButton<WorkPattern>(
        value: controller.selectedRequests[index].selectedPattern,
        hint: const Text("Pilih Shift"),
        isExpanded: true, // Pastikan dropdown mengisi SizedBox
        items: patterns.map((pattern) {
          return DropdownMenuItem<WorkPattern>(
            value: pattern,
            child: Text(
              pattern.name,
              overflow: TextOverflow.ellipsis, // Cegah teks panjang meluber
            ),
          );
        }).toList(),
        onChanged: (pattern) {
          if (pattern != null) {
            controller.updateSelectedPattern(index, pattern);
          }
        },
      ),
    );
  }
}
