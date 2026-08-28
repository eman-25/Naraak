import '../../models/service_request.dart';
import '../repository/request_repository.dart';

/// Mock replacement for the future Hajj certificate endpoint.
/// Replace this service with an API client when the production contract is
/// available. Phase 3 §3.6: this is a read-only check against a doctor visit
/// logged in the MOH DB, not something the user fills a form to request —
/// self-reporting "I've requested it" here stands in for that backend check.
class MockHajjCertificateService {
  static const serviceName = 'Electronic Hajj Certificate';

  final RequestRepository _repository = RequestRepository.instance;

  ServiceRequest? existingRequest() => _repository.latestFor(serviceName);

  Future<ServiceRequest> requestCertificate() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _repository.addRequest(
      serviceName: serviceName,
      status: 'processing',
      note: 'Awaiting certificate generation from your health center.',
    );
  }
}
