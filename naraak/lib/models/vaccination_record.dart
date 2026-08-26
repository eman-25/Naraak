/// Shaped to match Phase 5 /api/v1/vaccinations/{patientId}.
class VaccinationRecord {
  final String id;
  final String vaccineName;
  final DateTime dateAdministered;
  final bool isFlaggedMissing; // Phase 3: flags expected-but-missing records
  final String? certificateUrl;

  const VaccinationRecord({
    required this.id,
    required this.vaccineName,
    required this.dateAdministered,
    this.isFlaggedMissing = false,
    this.certificateUrl,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: json['id'] as String,
      vaccineName: json['vaccineName'] as String,
      dateAdministered: DateTime.parse(json['dateAdministered'] as String),
      isFlaggedMissing: json['isFlaggedMissing'] as bool? ?? false,
      certificateUrl: json['certificateUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vaccineName': vaccineName,
        'dateAdministered': dateAdministered.toIso8601String(),
        'isFlaggedMissing': isFlaggedMissing,
        'certificateUrl': certificateUrl,
      };
}
