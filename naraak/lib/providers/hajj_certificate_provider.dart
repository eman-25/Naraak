// lib/providers/hajj_certificate_provider.dart
import 'package:flutter/foundation.dart';
import '../models/hajj_trip_record.dart';
import '../models/service_request.dart';
import '../services_mock/mock/mock_hajj_certificate_service.dart';
import 'appointment_provider.dart' show LoadState;

class HajjCertificateProvider extends ChangeNotifier {
  final MockHajjCertificateService _service = MockHajjCertificateService();

  ServiceRequest? _existingRequest;
  LoadState _initState = LoadState.idle;
  LoadState _lookupState = LoadState.idle;
  HajjTripRecord? _foundTrip;
  bool _isSubmitting = false;
  String? _errorMessage;

  ServiceRequest? get existingRequest => _existingRequest;
  LoadState get initState => _initState;
  LoadState get lookupState => _lookupState;
  HajjTripRecord? get foundTrip => _foundTrip;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void checkExistingRequest() {
    _initState = LoadState.loading;
    notifyListeners();
    try {
      _existingRequest = _service.existingRequest();
      _initState = LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _initState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> lookupTrip(int hijriYear) async {
    _lookupState = LoadState.loading;
    _foundTrip = null;
    notifyListeners();
    try {
      final trip = await _service.findTrip(hijriYear);
      _foundTrip = trip;
      _lookupState = trip == null ? LoadState.empty : LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _lookupState = LoadState.error;
    }
    notifyListeners();
  }

  void resetLookup() {
    _lookupState = LoadState.idle;
    _foundTrip = null;
    notifyListeners();
  }

  Future<ServiceRequest?> submit() async {
    if (_foundTrip == null) return null;
    _isSubmitting = true;
    notifyListeners();
    try {
      final request = await _service.submit(trip: _foundTrip!);
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