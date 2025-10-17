class WorkProfile {
  final String employeeName;
  final String? jobTitle;
  final WorkPattern? workPattern;
  final StoreLocation? storeLocation;
  final String? imageUrl;

  WorkProfile({
    required this.employeeName,
    this.jobTitle,
    this.workPattern,
    this.storeLocation,
    this.imageUrl,
  });

  factory WorkProfile.fromJson(Map<String, dynamic> json) {
    final workPatternData = json['work_pattern'];
    final storeLocationData = json['store_location'];

    final jobTitleData = json['job_title'];

    return WorkProfile(
      employeeName: json['employee_name'] ?? 'No Name',
      jobTitle: jobTitleData is String ? jobTitleData : null,
      workPattern: (workPatternData != null &&
              workPatternData is Map<String, dynamic> &&
              workPatternData['name'] != false)
          ? WorkPattern.fromJson(workPatternData)
          : null,
      storeLocation: (storeLocationData != null &&
              storeLocationData is Map<String, dynamic> &&
              storeLocationData['name'] != false)
          ? StoreLocation.fromJson(storeLocationData)
          : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_name': employeeName,
      'job_title': jobTitle,
      'work_pattern': workPattern?.toJson(),
      'store_location': storeLocation?.toJson(),
    };
  }
}

class WorkPattern {
  final String name;
  final double workFrom;
  final double workTo;

  WorkPattern(
      {required this.name, required this.workFrom, required this.workTo});

  factory WorkPattern.fromJson(Map<String, dynamic> json) {
    return WorkPattern(
      name: json['name'] ?? 'N/A',
      workFrom: double.tryParse(json['work_from'].toString()) ?? 0.0,
      workTo: double.tryParse(json['work_to'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'work_from': workFrom,
      'work_to': workTo,
    };
  }
}

class StoreLocation {
  final String name;
  final double latitude;
  final double longitude;

  StoreLocation(
      {required this.name, required this.latitude, required this.longitude});

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      name: json['name'] ?? 'N/A',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
