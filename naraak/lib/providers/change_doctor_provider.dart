import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/health_center_option.dart';
import '../models/service_request.dart';
import 'appointment_provider.dart' show LoadState;

class ChangeDoctorProvider extends ChangeNotifier {
  ChangeDoctorProvider(this.repository);
  final NaraakRepository repository;
  LoadState _initState = LoadState.idle;
  bool _hasPendingRequest = false;
  List<HealthCenterOption> _centers = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  final Map<String, String> _doctorIds = {};
  LoadState get initState => _initState;
  bool get hasPendingRequest => _hasPendingRequest;
  List<HealthCenterOption> get centers => _centers;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Future<void> init() async {
    _initState = LoadState.loading;
    notifyListeners();
    try {
      final profile = await repository.profile();
      final center = Map<String, dynamic>.from(profile['healthCenter'] as Map);
      final pending = await repository.api.getPendingRequests(
          patientId: repository.requirePatientId, status: 'submitted');
      final requests = repository.data(pending) as List;
      _hasPendingRequest = requests
          .any((r) => (r as Map)['serviceType'] == 'family-doctor-change');
      final response = await repository.api
          .getAvailableFamilyDoctors(healthCenterId: center['id'] as String);
      final doctors = (repository.data(response) as List)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((v) => v['capacityAvailable'] == true)
          .toList();
      _doctorIds
        ..clear()
        ..addEntries(doctors.map((v) =>
            MapEntry(v['doctorName'] as String, v['doctorId'] as String)));
      _centers = [
        HealthCenterOption(
            name: center['name'] as String,
            doctors: doctors.map((v) => v['doctorName'] as String).toList())
      ];
      _initState = LoadState.success;
    } catch (e) {
      _errorMessage = repository.friendlyError(e, arabic: false);
      _initState = LoadState.error;
    }
    notifyListeners();
  }

  Future<ServiceRequest?> submit(
      {required String currentDoctor,
      required String newCenter,
      required String newDoctor,
      required String reason}) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final response = await repository.api.requestFamilyDoctorChange(
          patientId: repository.requirePatientId,
          requestedDoctorId: _doctorIds[newDoctor] ?? '',
          reason: reason,
          consent: true);
      final request = ServiceRequest.fromJson(
          Map<String, dynamic>.from(repository.data(response) as Map));
      _isSubmitting = false;
      notifyListeners();
      return request;
    } catch (e) {
      _errorMessage = repository.friendlyError(e, arabic: false);
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }
}
