import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/appointment.dart';

enum LoadState { idle, loading, success, empty, error }

class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider(this.repository);
  final NaraakRepository repository;

  List<Appointment> _availableSlots = [];
  List<Appointment> _myAppointments = [];
  List<String> _clinics = [];
  LoadState _slotsState = LoadState.idle;
  String? _errorMessage;

  List<Appointment> get availableSlots => List.unmodifiable(_availableSlots);
  List<Appointment> get myAppointments => List.unmodifiable(_myAppointments);
  List<String> get clinics => List.unmodifiable(_clinics);
  LoadState get slotsState => _slotsState;
  String? get errorMessage => _errorMessage;

  Future<void> loadClinics({required String appointmentType}) async {
    try {
      final response = await repository.api
          .getAppointmentClinics(appointmentType: appointmentType);
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      _clinics = List<String>.from(data['clinics'] as List);
      notifyListeners();
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
    }
  }

  Future<void> loadAvailableSlots(
      {String? centerId,
      String appointmentType = 'in-center',
      String clinic = 'General Clinic',
      String? doctorId,
      String? doctorGender,
      String? date,
      bool earliestAvailable = false}) async {
    _slotsState = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await repository.api.getAppointmentSlots(
        appointmentType: appointmentType,
        clinic: clinic,
        healthCenterId: centerId,
        doctorId: doctorId,
        doctorGender: doctorGender,
        date: date,
        earliestAvailable: earliestAvailable,
      );
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      _availableSlots = (data['appointments'] as List)
          .map((item) =>
              Appointment.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      _slotsState =
          _availableSlots.isEmpty ? LoadState.empty : LoadState.success;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      _slotsState = LoadState.error;
    }
    notifyListeners();
  }

  Future<bool> bookSlot(String slotId,
      {String appointmentType = 'in-center'}) async {
    try {
      await repository.api.bookAppointment(
          patientId: repository.requirePatientId,
          slotId: slotId,
          appointmentType: appointmentType);
      await Future.wait([
        loadMyAppointments(),
        loadAvailableSlots(appointmentType: appointmentType)
      ]);
      return true;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
      return false;
    }
  }

  Future<Appointment> bookTeleAppointment() async {
    await loadAvailableSlots(appointmentType: 'tele', earliestAvailable: true);
    if (_availableSlots.isEmpty)
      throw StateError(_errorMessage ?? 'No tele-appointment is available.');
    final slot = _availableSlots.first;
    final response = await repository.api.bookAppointment(
        patientId: repository.requirePatientId,
        slotId: slot.slotId ?? slot.id,
        appointmentType: 'tele');
    final booked = Appointment.fromJson(
        Map<String, dynamic>.from(repository.data(response) as Map));
    await loadMyAppointments();
    return booked;
  }

  Future<void> loadMyAppointments() async {
    try {
      final response = await repository.api
          .getMyAppointments(patientId: repository.requirePatientId);
      _myAppointments = (repository.data(response) as List)
          .map((item) =>
              Appointment.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      notifyListeners();
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getTeleDetails(String appointmentId) async =>
      Map<String, dynamic>.from(repository.data(await repository.api
          .getTeleAppointmentDetails(appointmentId: appointmentId)) as Map);

  Future<bool> resendTeleLink(String appointmentId) async {
    try {
      await repository.api.resendTeleLink(appointmentId: appointmentId);
      return true;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelAppointment(String id) async {
    _errorMessage =
        'Cancelling appointments is not supported by the current API contract.';
    notifyListeners();
  }
}
