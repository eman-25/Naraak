import '../../models/vaccination_record.dart';

/// Mock replacement for /api/v1/vaccinations/{patientId} and its
/// /certificate endpoint (Phase 5, Section 3).
class MockVaccinationService {
  final List<VaccinationRecord> _records = [
    VaccinationRecord(
      id: 'vac_001',
      vaccineName: 'MMR (Measles, Mumps, Rubella)',
      dateAdministered: DateTime(2019, 3, 12),
    ),
    VaccinationRecord(
      id: 'vac_002',
      vaccineName: 'DTaP Booster',
      dateAdministered: DateTime(2022, 6, 4),
      certificateUrl: 'mock://certificates/vac_002.pdf',
    ),
    VaccinationRecord(
      id: 'vac_003',
      vaccineName: 'Hepatitis B — 3rd dose',
      dateAdministered: DateTime(2024, 1, 20),
      isFlaggedMissing: true, // demo: expected-but-missing, per Phase 3 flag behavior
    ),
  ];

  /// GET /api/v1/vaccinations/{patientId}
  Future<List<VaccinationRecord>> getRecords({String? patientId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_records);
  }

  /// GET /api/v1/vaccinations/{patientId}/certificate
  Future<String> getCertificateUrl(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final record = _records.firstWhere(
      (r) => r.id == recordId,
      orElse: () => throw Exception('NOT_FOUND: No certificate found for this record'),
    );
    if (record.certificateUrl == null) {
      throw Exception('NOT_FOUND: certificate not yet available');
    }
    return record.certificateUrl!;
  }

  /// Report a missing record with a supporting document upload (simulated).
  Future<void> reportMissingRecord({
    required String vaccineName,
    required String fakeFileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulated file type/size validation, per Phase 3 decision points.
    final validExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];
    final isValid = validExtensions.any((ext) => fakeFileName.toLowerCase().endsWith(ext));
    if (!isValid) {
      throw Exception('VALIDATION_ERROR: unsupported file type');
    }
    // In a real backend this would create a tracked request; here we just
    // acknowledge receipt for demo purposes.
  }
}
