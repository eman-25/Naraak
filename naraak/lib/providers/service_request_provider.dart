import 'package:flutter/foundation.dart';
import '../models/service_request.dart';
import '../services_mock/mock/mock_service_request_service.dart';
import 'appointment_provider.dart' show LoadState;

class ServiceRequestProvider extends ChangeNotifier {
  final MockServiceRequestService _service = MockServiceRequestService();

  List<ServiceRequest> _requests = [];
  LoadState _state = LoadState.idle;
  String? _errorMessage;

  List<ServiceRequest> get requests => _requests;
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Requests still awaiting an outcome — used for a badge count elsewhere if needed.
  int get openCount =>
      _requests.where((r) => r.status == 'submitted' || r.status == 'processing').length;

  Future<void> loadRequests() async {
    _state = LoadState.loading;
    notifyListeners();

    try {
      final result = await _service.getRequests();
      _requests = result;
      _state = result.isEmpty ? LoadState.empty : LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LoadState.error;
    }
    notifyListeners();
  }
}