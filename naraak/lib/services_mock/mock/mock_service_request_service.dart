import '../../models/service_request.dart';

/// Mock backing store for every request-based service that shares the
/// requestId/status shape from Phase 5 §3 (Hajj Certificate, Fee Exemption,
/// Mobile Unit, PHC Research, Newborn Sehati Card, Mammogram, Change Doctor).
/// A real backend would instead aggregate each service's own status
/// endpoint; here we keep one in-memory list for the demo.
class MockServiceRequestService {
  final List<ServiceRequest> _requests = [
    ServiceRequest(
      id: 'req_001',
      serviceName: 'Electronic Hajj Certificate',
      status: 'processing',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      note: 'Awaiting certificate generation',
    ),
    ServiceRequest(
      id: 'req_002',
      serviceName: 'Health Fee Exemption Card',
      status: 'submitted',
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ServiceRequest(
      id: 'req_003',
      serviceName: 'Change Family Doctor',
      status: 'approved',
      submittedAt: DateTime.now().subtract(const Duration(days: 6)),
      note: 'Reassignment confirmed',
    ),
    ServiceRequest(
      id: 'req_004',
      serviceName: 'PHC Research Application',
      status: 'rejected',
      submittedAt: DateTime.now().subtract(const Duration(days: 10)),
      note: 'Missing supervisor approval letter',
    ),
  ];

  /// GET aggregated pending/recent requests across all request-based services.
  Future<List<ServiceRequest>> getRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_requests);
  }

  /// Convenience filter — requests still awaiting an outcome.
  Future<List<ServiceRequest>> getOpenRequests() async {
    final all = await getRequests();
    return all.where((r) => r.status == 'submitted' || r.status == 'processing').toList();
  }
}