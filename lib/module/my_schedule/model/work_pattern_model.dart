class WorkPattern {
  final int id;
  final String name;
  final double workFrom; // <-- 1. TAMBAHKAN PROPERTI INI
  final double workTo;

  WorkPattern(
      {required this.id,
      required this.name,
      required this.workFrom,
      required this.workTo});

  factory WorkPattern.fromJson(Map<String, dynamic> json) {
    return WorkPattern(
      id: json['id'],
      name: json['name'],
      workFrom: (json['work_from'] as num?)?.toDouble() ?? 0.0,
      workTo: (json['work_to'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
