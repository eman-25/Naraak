import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/service_request.dart';
import 'appointment_provider.dart' show LoadState;

class FeeExemptionProvider extends ChangeNotifier {
  FeeExemptionProvider(this.repository);
  final NaraakRepository repository;
  LoadState _initState = LoadState.idle;
  bool _hasPendingRequest = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<Map<String, dynamic>> checklist = [];
  LoadState get initState => _initState;
  bool get hasPendingRequest => _hasPendingRequest;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<String> get categories =>
      const ['Medical', 'Social support', 'Disability', 'Other'];
  Future<void> init() async {
    _initState = LoadState.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.api.getPendingRequests(
            patientId: repository.requirePatientId, status: 'submitted'),
        repository.api.getFeeExemptionDocumentChecklist()
      ]);
      final requests = repository.data(results[0]) as List;
      _hasPendingRequest =
          requests.any((r) => (r as Map)['serviceType'] == 'fee-exemption');
      checklist = (repository.data(results[1]) as List)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
      _initState = LoadState.success;
    } catch (e) {
      _errorMessage = repository.friendlyError(e, arabic: false);
      _initState = LoadState.error;
    }
    notifyListeners();
  }

  String? validateDocument(String fileName) {
    final lower = fileName.toLowerCase();
    return ['.pdf', '.jpg', '.jpeg', '.png'].any(lower.endsWith)
        ? null
        : 'Upload a PDF, JPG, or PNG file.';
  }

  Future<ServiceRequest?> submit(
      {required String category,
      required String documentName,
      required String mobile}) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final response = await repository.api.submitFeeExemption(
          patientId: repository.requirePatientId,
          requestType: category,
          personalDetails: {'mobile': mobile, 'category': category},
          supportingDocuments: [documentName],
          consent: true);
      final request = ServiceRequest.fromJson(
          Map<String, dynamic>.from(repository.data(response) as Map));
      _isSubmitting = false;
      notifyListeners();
      return request;
    } catch (e) {
      _errorMessage = repository.friendlyError(e, arabic: false);
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }
}
