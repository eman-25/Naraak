import 'package:flutter/foundation.dart';
import '../models/health_center_option.dart';
import '../models/service_request.dart';
import '../services_mock/mock/mock_change_doctor_service.dart';
import 'appointment_provider.dart' show LoadState;

/// Provider wrapping MockChangeDoctorService — screens listen to this
/// instead of calling the mock service directly, per Phase 6 §6.
class ChangeDoctorProvider extends ChangeNotifier {
  final MockChangeDoctorService _service = MockChangeDoctorService();

  LoadState _initState = LoadState.idle;
  bool _hasPendingRequest = false;
  List<HealthCenterOption> _centers = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  LoadState get initState => _initState;
  bool get hasPendingRequest => _hasPendingRequest;
  List<HealthCenterOption> get centers => _centers;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Runs the "already have a pending request?" decision point and loads
  /// the center/doctor directory together, before the flow starts.
  Future<void> init() async {
    _initState = LoadState.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.hasPendingRequest(),
        _service.getHealthCenters(),
      ]);
      _hasPendingRequest = results[0] as bool;
      _centers = results[1] as List<HealthCenterOption>;
      _initState = LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _initState = LoadState.error;
    }
    notifyListeners();
  }

  Future<ServiceRequest?> submit({
    required String currentDoctor,
    required String newCenter,
    required String newDoctor,
    required String reason,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final request = await _service.submit(
        currentDoctor: currentDoctor,
        newCenter: newCenter,
        newDoctor: newDoctor,
        reason: reason,
      );
      _isSubmitting = false;
      notifyListeners();
      return request;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }
}
