import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/service_request.dart';
import 'appointment_provider.dart' show LoadState;

class ServiceRequestProvider extends ChangeNotifier {
  ServiceRequestProvider(this.repository);
  final NaraakRepository repository;
  List<ServiceRequest> _requests = [];
  LoadState _state = LoadState.idle;
  String? _errorMessage;
  List<ServiceRequest> get requests => List.unmodifiable(_requests);
  LoadState get state => _state;
  String? get errorMessage => _errorMessage;
  int get openCount => _requests.where((r) => r.isOpen).length;

  Future<void> loadRequests() async {
    _state = LoadState.loading;
    notifyListeners();
    try {
      final response = await repository.api
          .getPendingRequests(patientId: repository.requirePatientId);
      _requests = (repository.data(response) as List)
          .map((item) =>
              ServiceRequest.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      _state = _requests.isEmpty ? LoadState.empty : LoadState.success;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      _state = LoadState.error;
    }
    notifyListeners();
  }

  Future<ServiceRequest?> getById(String id) async {
    try {
      final response = await repository.api.getRequestById(requestId: id);
      return ServiceRequest.fromJson(
          Map<String, dynamic>.from(repository.data(response) as Map));
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
      return null;
    }
  }
}
