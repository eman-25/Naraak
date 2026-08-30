import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/vaccination_record.dart';
import 'appointment_provider.dart' show LoadState;

class VaccinationProvider extends ChangeNotifier {
  VaccinationProvider(this.repository);
  final NaraakRepository repository;
  List<VaccinationRecord> _records = [];
  LoadState _state = LoadState.idle;
  String? _errorMessage;
  List<VaccinationRecord> get records => List.unmodifiable(_records);
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecords() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      final response = await repository.api
          .getVaccinations(patientId: repository.requirePatientId);
      _records = (repository.data(response) as List)
          .map((item) => VaccinationRecord.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList();
      _state = _records.isEmpty ? LoadState.empty : LoadState.success;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<String?> getCertificateUrl(String recordId) async => _records
          .where((record) => record.id == recordId)
          .isEmpty
      ? null
      : _records.firstWhere((record) => record.id == recordId).certificateUrl;

  Future<bool> reportMissingRecord(
      {required String vaccineName,
      required String fakeFileName,
      String? contactNumber,
      String? comments}) async {
    try {
      await repository.api.reportMissingVaccination(
          patientId: repository.requirePatientId,
          uploadedDocument: fakeFileName,
          contactNumber: contactNumber ?? '',
          comments: comments ?? vaccineName);
      return true;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
      return false;
    }
  }
}
