// lib/module/my_schedule/model/my_schedule_model.dart
import 'package:get/get.dart';

class Roster {
  final int id;
  final DateTime date;
  final String status;
  final String workPatternName;
  final String? rejectionReason;
  final DateTime? createDate;
  final double? workFrom;
  final double? workTo;

  Roster({
    required this.id,
    required this.date,
    required this.status,
    required this.workPatternName,
    this.rejectionReason,
    this.createDate,
    this.workFrom,
    this.workTo,
  });

  factory Roster.fromJson(Map<String, dynamic> json) {
    return Roster(
      id: json['id'],
      date: DateTime.parse(json['date']),
      workPatternName: json['work_pattern_name'] ?? 'No Shift Name',
      status: json['state']?.toString().capitalizeFirst ?? 'Draft',
      rejectionReason:
          json['rejection_reason'] is bool ? null : json['rejection_reason'],
      createDate: json['create_date'] != null
          ? DateTime.parse(json['create_date'])
          : null,
      workFrom: (json['work_from'] as num?)?.toDouble(),
      workTo: (json['work_to'] as num?)?.toDouble(),
    );
  }
}
