import 'package:flutter/foundation.dart';
import '../models/vaccination_record.dart';
import '../services_mock/mock/mock_vaccination_service.dart';
import 'appointment_provider.dart' show LoadState;

class VaccinationProvider extends ChangeNotifier {
  final MockVaccinationService _service = MockVaccinationService();

  List<VaccinationRecord> _records = [];
  LoadState _state = LoadState.idle;
  String? _errorMessage;

  List<VaccinationRecord> get records => _records;
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecords() async {
    _state = LoadState.loading;
    notifyListeners();

    try {
      final result = await _service.getRecords();
      _records = result;
      _state = result.isEmpty ? LoadState.empty : LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<String?> getCertificateUrl(String recordId) async {
    try {
      return await _service.getCertificateUrl(recordId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> reportMissingRecord({
    required String vaccineName,
    required String fakeFileName,
  }) async {
    try {
      await _service.reportMissingRecord(
        vaccineName: vaccineName,
        fakeFileName: fakeFileName,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
