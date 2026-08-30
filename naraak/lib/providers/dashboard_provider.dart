import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import 'appointment_provider.dart' show LoadState;

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this.repository);
  final NaraakRepository repository;
  LoadState state = LoadState.idle;
  Map<String, dynamic>? dashboard;
  String? errorMessage;
  int get unreadNotifications => dashboard?['unreadNotifications'] as int? ?? 0;

  Future<void> load() async {
    state = LoadState.loading;
    notifyListeners();
    try {
      dashboard = await repository.dashboard();
      state = LoadState.success;
    } catch (error) {
      errorMessage = repository.friendlyError(error, arabic: false);
      state = LoadState.error;
    }
    notifyListeners();
  }
}
