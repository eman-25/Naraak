import 'package:flutter/foundation.dart';
import '../models/service_request.dart';
import '../services_mock/mock/mock_fee_exemption_service.dart';
import 'appointment_provider.dart' show LoadState;

/// Provider wrapping MockFeeExemptionService — screens listen to this
/// instead of calling the mock service directly, per Phase 6 §6.
class FeeExemptionProvider extends ChangeNotifier {
  final MockFeeExemptionService _service = MockFeeExemptionService();

  LoadState _initState = LoadState.idle;
  bool _hasPendingRequest = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  LoadState get initState => _initState;
  bool get hasPendingRequest => _hasPendingRequest;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  List<String> get categories => MockFeeExemptionService.eligibilityCategories;

  Future<void> init() async {
    _initState = LoadState.loading;
    notifyListeners();
    try {
      _hasPendingRequest = await _service.hasPendingRequest();
      _initState = LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _initState = LoadState.error;
    }
    notifyListeners();
  }

  /// Returns an error message if [fileName] fails validation, else null.
  String? validateDocument(String fileName) => _service.validateDocument(fileName);

  Future<ServiceRequest?> submit({
    required String category,
    required String documentName,
    required String mobile,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final request = await _service.submit(
        category: category,
        documentName: documentName,
        mobile: mobile,
      );
      _isSubmitting = false;
      notifyListeners();
      return request;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }
}
