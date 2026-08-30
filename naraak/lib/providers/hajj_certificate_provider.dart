import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/service_request.dart';
import 'appointment_provider.dart' show LoadState;

class HajjCertificateProvider extends ChangeNotifier {
  HajjCertificateProvider(this.repository);
  final NaraakRepository repository;
  ServiceRequest? _existingRequest;
  LoadState _initState = LoadState.idle;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? certificateReference;
  ServiceRequest? get existingRequest => _existingRequest;
  LoadState get initState => _initState;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Future<void> checkExistingRequest() async {
    _initState = LoadState.loading;
    notifyListeners();
    try {
      final response = await repository.api
          .getHajjCertificateStatus(patientId: repository.requirePatientId);
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      certificateReference = data['certificateReference'] as String?;
      _existingRequest = ServiceRequest(
          id: 'hajj-${repository.requirePatientId}',
          serviceName: 'hajj-certificate',
          status: data['status'] as String,
          submittedAt: DateTime.now(),
          attachmentName: certificateReference);
      _initState = LoadState.success;
    } catch (e) {
      _errorMessage = repository.friendlyError(e, arabic: false);
      _initState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> requestCertificate() async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final response = await repository.api
          .requestHajjCertificate(patientId: repository.requirePatientId);
      _existingRequest = ServiceRequest.fromJson(
          Map<String, dynamic>.from(repository.data(response) as Map));
    } catch (e) {
      _errorMessage = repository.friendlyError(e, arabic: false);
    }
    _isSubmitting = false;
    notifyListeners();
  }
}
