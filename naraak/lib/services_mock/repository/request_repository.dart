import '../../models/service_request.dart';

/// In-memory request store shared by the mock service implementations.
class RequestRepository {
  RequestRepository._();

  static final RequestRepository instance = RequestRepository._();

  final List<ServiceRequest> _requests = [];
  int _nextId = 1;

  List<ServiceRequest> getAll() => List.unmodifiable(_requests);

  bool hasOpenRequestFor(String serviceName) {
    return _requests
        .any((request) => request.serviceName == serviceName && request.isOpen);
  }

  ServiceRequest? latestFor(String serviceName) {
    for (final request in _requests.reversed) {
      if (request.serviceName == serviceName) {
        return request;
      }
    }
    return null;
  }

  ServiceRequest addRequest({
    required String serviceName,
    required String status,
    String? note,
    String? attachmentName,
  }) {
    final request = ServiceRequest(
      id: 'REQ-${_nextId++}',
      serviceName: serviceName,
      status: status,
      submittedAt: DateTime.now(),
      note: note,
      attachmentName: attachmentName,
    );
    _requests.add(request);
    return request;
  }
}
