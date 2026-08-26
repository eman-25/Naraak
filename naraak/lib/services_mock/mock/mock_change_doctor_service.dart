import '../../data/health_centers.dart';
import '../../models/health_center_option.dart';
import '../../models/service_request.dart';
import '../repository/request_repository.dart';

/// Mock replacement for the future family-doctor change endpoint.
/// Replace this service with an API client when the production contract is available.
class MockChangeDoctorService {
  static const serviceName = 'Change Family Doctor';

  final RequestRepository _repository = RequestRepository.instance;

  Future<bool> hasPendingRequest() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _repository.hasOpenRequestFor(serviceName);
  }

  Future<List<HealthCenterOption>> getHealthCenters() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return kHealthCenters;
  }

  Future<ServiceRequest> submit({
    required String currentDoctor,
    required String newCenter,
    required String newDoctor,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _repository.addRequest(
      serviceName: serviceName,
      status: 'submitted',
      note:
          'Transfer from $currentDoctor to $newDoctor at $newCenter. Reason: $reason',
    );
  }
}
