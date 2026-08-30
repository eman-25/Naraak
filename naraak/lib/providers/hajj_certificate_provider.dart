// lib/providers/hajj_certificate_provider.dart
import 'package:flutter/foundation.dart';
import '../models/service_request.dart';
import '../services_mock/mock/mock_hajj_certificate_service.dart';
import 'appointment_provider.dart' show LoadState;

class HajjCertificateProvider extends ChangeNotifier {
  final MockHajjCertificateService _service = MockHajjCertificateService();

  ServiceRequest? _existingRequest;
  LoadState _initState = LoadState.idle;
  bool _isSubmitting = false;
  String? _errorMessage;

  ServiceRequest? get existingRequest => _existingRequest;
  LoadState get initState => _initState;
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

  Future<void> requestCertificate() async {
    _isSubmitting = true;
    notifyListeners();
    try {
      _existingRequest = await _service.requestCertificate();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isSubmitting = false;
    notifyListeners();
  }
}
