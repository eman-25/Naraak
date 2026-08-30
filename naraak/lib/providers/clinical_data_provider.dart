import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/api_notification.dart';
import '../models/medical_report.dart';
import 'appointment_provider.dart' show LoadState;

class ClinicalDataProvider extends ChangeNotifier {
  ClinicalDataProvider(this.repository);
  final NaraakRepository repository;
  List<MedicalReport> reports = [];
  List<ApiNotification> notifications = [];
  LoadState reportsState = LoadState.idle;
  LoadState notificationsState = LoadState.idle;
  String? errorMessage;
  int get unreadCount => notifications.where((item) => !item.read).length;

  Future<void> loadReports({String? category}) async {
    reportsState = LoadState.loading;
    notifyListeners();
    try {
      final response = await repository.api.getMedicalReports(
          patientId: repository.requirePatientId, type: category);
      reports = (repository.data(response) as List)
          .map((item) =>
              MedicalReport.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      reportsState = reports.isEmpty ? LoadState.empty : LoadState.success;
    } catch (error) {
      errorMessage = repository.friendlyError(error, arabic: false);
      reportsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> loadConsultants(String category) async {
    final response =
        await repository.api.getVisitedConsultants(category: category);
    return (repository.data(response) as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> loadNotifications({bool unreadOnly = false}) async {
    notificationsState = LoadState.loading;
    notifyListeners();
    try {
      final response = await repository.api.getNotifications(
          patientId: repository.requirePatientId, unreadOnly: unreadOnly);
      notifications = (repository.data(response) as List)
          .map((item) =>
              ApiNotification.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      notificationsState =
          notifications.isEmpty ? LoadState.empty : LoadState.success;
    } catch (error) {
      errorMessage = repository.friendlyError(error, arabic: false);
      notificationsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    try {
      await repository.api.markNotificationRead(notificationId: id);
      notifications = [
        for (final item in notifications)
          item.id == id ? item.copyWith(read: true) : item
      ];
      notifyListeners();
    } catch (error) {
      errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
    }
  }
}
