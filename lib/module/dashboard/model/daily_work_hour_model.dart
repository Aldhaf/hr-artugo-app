enum WorkDayStatus { worked, absent, holiday }

class DailyWorkHour {
  final DateTime date;
  final double hours;
  final WorkDayStatus status;

  DailyWorkHour({
    required this.date,
    required this.hours,
    this.status = WorkDayStatus.worked,
  });
}