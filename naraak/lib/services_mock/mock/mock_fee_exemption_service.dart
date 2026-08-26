import '../../models/service_request.dart';
import '../repository/request_repository.dart';

/// Mock replacement for the future fee-exemption endpoint.
/// Replace this service with an API client when the production contract is available.
class MockFeeExemptionService {
  static const serviceName = 'Health Fee Exemption Card';

  static const eligibilityCategories = [
    'Government Employee',
    'Senior Citizen (60+)',
    'Person with Disability',
    'Low-Income Household',
    'GCC National',
  ];

  static const _validExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];
  static const _maxSizeKb = 5000;

  final RequestRepository _repository = RequestRepository.instance;

  Future<bool> hasPendingRequest() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _repository.hasOpenRequestFor(serviceName);
  }

  String? validateDocument(String fileName, {int fakeSizeKb = 800}) {
    final lowerName = fileName.toLowerCase();
    if (!_validExtensions.any(lowerName.endsWith)) {
      return 'Unsupported file type. Please upload a PDF, JPG, or PNG.';
    }
    if (fakeSizeKb > _maxSizeKb) {
      return 'File is too large. Maximum size is 5MB.';
    }
    return null;
  }

  Future<ServiceRequest> submit({
    required String category,
    required String documentName,
    required String mobile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _repository.addRequest(
      serviceName: serviceName,
      status: 'submitted',
      note: 'Category: $category. Contact: $mobile',
      attachmentName: documentName,
    );
  }
}
