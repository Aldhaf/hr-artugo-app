import 'package:hr_artugo_app/module/my_schedule/model/work_pattern_model.dart';

class ScheduleRequest {
  DateTime date;
  WorkPattern? selectedPattern;

  ScheduleRequest({required this.date, this.selectedPattern});
}