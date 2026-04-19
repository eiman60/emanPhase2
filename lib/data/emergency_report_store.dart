import 'package:flutter/foundation.dart';

class EmergencyReport {
  EmergencyReport({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.taken = false,
  });

  final String id;
  final String type;
  final String typeLabel;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final bool taken;

  EmergencyReport copyWith({bool? taken}) {
    return EmergencyReport(
      id: id,
      type: type,
      typeLabel: typeLabel,
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      taken: taken ?? this.taken,
    );
  }
}

class EmergencyReportStore {
  static final ValueNotifier<List<EmergencyReport>> reports =
      ValueNotifier<List<EmergencyReport>>(<EmergencyReport>[]);

  static void add(EmergencyReport report) {
    reports.value = <EmergencyReport>[report, ...reports.value];
  }

  static void toggleTaken(String id) {
    reports.value = reports.value
        .map(
          (report) => report.id == id
              ? report.copyWith(taken: !report.taken)
              : report,
        )
        .toList();
  }
}
