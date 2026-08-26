import '../../models/service_request.dart';
import '../repository/request_repository.dart';

/// Mock replacement for the future aggregated requests endpoint.
/// In production, replace this with a repository/API client call such as
/// GET /api/v1/requests.
class MockServiceRequestService {
  final RequestRepository _repository = RequestRepository.instance;

  Future<List<ServiceRequest>> getRequests() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _repository.getAll();
  }
}
