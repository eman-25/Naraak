/// Shaped to match Phase 5 /api/v1/vaccinations/{patientId}.
class VaccinationRecord {
  final String id;
  final String vaccineName;
  final DateTime dateAdministered;
  final bool isFlaggedMissing; // Phase 3: flags expected-but-missing records
  final String? certificateUrl;
  final String healthCenter;
  final String dose;
  // Phase 3 §15 filter chips: 'Childhood' | 'Adult' | 'Travel'.
  final String category;

  const VaccinationRecord({
    required this.id,
    required this.vaccineName,
    required this.dateAdministered,
    this.isFlaggedMissing = false,
    this.certificateUrl,
    this.healthCenter = '',
    this.dose = '',
    this.category = 'Adult',
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: (json['recordId'] ?? json['id']) as String,
      vaccineName: json['vaccineName'] as String,
      dateAdministered: DateTime.parse(
          (json['vaccinationDate'] ?? json['dateAdministered']) as String),
      isFlaggedMissing:
          (json['missing'] ?? json['isFlaggedMissing']) as bool? ?? false,
      certificateUrl:
          (json['certificateReference'] ?? json['certificateUrl']) as String?,
      healthCenter: json['healthCenter'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      category: json['category'] as String? ?? 'Adult',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vaccineName': vaccineName,
        'dateAdministered': dateAdministered.toIso8601String(),
        'isFlaggedMissing': isFlaggedMissing,
        'certificateUrl': certificateUrl,
        'healthCenter': healthCenter,
        'dose': dose,
        'category': category,
      };
}
