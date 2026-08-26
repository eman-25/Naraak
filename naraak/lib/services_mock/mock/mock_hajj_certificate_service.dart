import '../../models/hajj_trip_record.dart';
import '../../models/service_request.dart';
import '../repository/request_repository.dart';

/// Mock replacement for the future Hajj certificate endpoint.
/// Replace this service with an API client when the production contract is available.
class MockHajjCertificateService {
  static const serviceName = 'Electronic Hajj Certificate';

  static const _records = <int, HajjTripRecord>{
    1445: HajjTripRecord(
      hijriYear: 1445,
      operatorName: 'Al-Baraka Hajj & Umrah Group',
      groupNumber: 'BHR-1445-0231',
    ),
    1444: HajjTripRecord(
      hijriYear: 1444,
      operatorName: 'Gulf Pilgrims Services',
      groupNumber: 'BHR-1444-0119',
    ),
  };

  final RequestRepository _repository = RequestRepository.instance;

  ServiceRequest? existingRequest() => _repository.latestFor(serviceName);

  Future<HajjTripRecord?> findTrip(int hijriYear) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _records[hijriYear];
  }

  Future<ServiceRequest> submit({required HajjTripRecord trip}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _repository.addRequest(
      serviceName: serviceName,
      status: 'processing',
      note:
          'Trip ${trip.groupNumber} (${trip.operatorName}) - awaiting certificate generation',
    );
  }
}
