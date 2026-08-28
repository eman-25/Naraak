import 'package:flutter/foundation.dart';
import '../models/appointment.dart';
import '../services_mock/mock/mock_appointment_service.dart';

enum LoadState { idle, loading, success, empty, error }

/// Provider wrapping MockAppointmentService — screens listen to this
/// instead of calling the mock service directly, per Phase 6 Section 6
/// (Provider recommended as the default state management approach).
class AppointmentProvider extends ChangeNotifier {
  final MockAppointmentService _service = MockAppointmentService();

  List<Appointment> _availableSlots = [];
  List<Appointment> _myAppointments = [];
  LoadState _slotsState = LoadState.idle;
  String? _errorMessage;

  List<Appointment> get availableSlots => _availableSlots;
  List<Appointment> get myAppointments => _myAppointments;
  LoadState get slotsState => _slotsState;
  String? get errorMessage => _errorMessage;

  Future<void> loadAvailableSlots({String? centerId}) async {
    _slotsState = LoadState.loading;
    notifyListeners();

    try {
      final slots = await _service.getAvailableSlots(centerId: centerId);
      _availableSlots = slots;
      _slotsState = slots.isEmpty ? LoadState.empty : LoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _slotsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> bookSlot(String slotId) async {
    try {
      final booked = await _service.bookSlot(slotId);
      _availableSlots.removeWhere((s) => s.id == slotId);
      _myAppointments = [..._myAppointments, booked];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Appointment> bookTeleAppointment() async {
    final booked = await _service.bookTeleAppointment();
    _myAppointments = [..._myAppointments, booked];
    notifyListeners();
    return booked;
  }

  Future<void> loadMyAppointments() async {
    _myAppointments = await _service.getMyAppointments();
    notifyListeners();
  }

  Future<void> cancelAppointment(String id) async {
    await _service.cancelAppointment(id);
    _myAppointments = [
      for (final appointment in _myAppointments)
        if (appointment.id == id)
          appointment.copyWith(status: 'cancelled')
        else
          appointment,
    ];
    notifyListeners();
  }
}
