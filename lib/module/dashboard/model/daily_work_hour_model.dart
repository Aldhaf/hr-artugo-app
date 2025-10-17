enum WorkDayStatus { worked, absent, holiday }

class DailyWorkHour {
  final DateTime date;
  final double hours;
  final WorkDayStatus status; // Opsional, tapi bagus untuk styling

  DailyWorkHour({
    required this.date,
    required this.hours,
    this.status = WorkDayStatus.worked,
  });
}