import '../../models/appointment.dart';

/// Mock replacement for the future /api/v1/appointments endpoints
/// (Phase 5, Section 3). Simulates a 400-800ms network delay so
/// loading states are demonstrable, per the Phase 6 mock data strategy.
class MockAppointmentService {
  // In-memory "database" for this demo session.
  final List<Appointment> _slots = [
    Appointment(
      id: 'slot_today',
      centerName: 'Naim Health Center',
      doctorName: 'Dr. Fatima Al-Dosari',
      slotDateTime: DateTime.now().add(const Duration(hours: 2)),
      status: 'available',
    ),
    Appointment(
      id: 'slot_001',
      centerName: 'Hoora Health Center',
      doctorName: 'Dr. Layla Al-Ansari',
      slotDateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      status: 'available',
    ),
    Appointment(
      id: 'slot_002',
      centerName: 'Hoora Health Center',
      doctorName: 'Dr. Yousif Al-Kooheji',
      slotDateTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
      status: 'available',
    ),
    Appointment(
      id: 'slot_003',
      centerName: 'Muharraq Health Center',
      doctorName: 'Dr. Layla Al-Ansari',
      slotDateTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
      status: 'available',
    ),
  ];

  final List<Appointment> _myAppointments = [];
  int _teleCounter = 0;

  /// GET /api/v1/appointments
  Future<List<Appointment>> getAvailableSlots({
    String? centerId,
    DateTime? date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Demo: fictional CPR / patient names only, never real data.
    final results = _slots.where((s) => s.status == 'available').toList();

    // Simulate an occasional empty state so it can be demoed on demand
    // by filtering to a center that has no fictional slots.
    if (centerId == 'no-results-demo') return [];

    return results;
  }

  /// POST /api/v1/appointments
  Future<Appointment> bookSlot(String slotId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _slots.indexWhere((s) => s.id == slotId);
    if (index == -1) {
      throw Exception(
          'CONFLICT: slot no longer available'); // maps to Phase 5 error code 409
    }

    final booked = _slots[index].copyWith(status: 'confirmed');
    _slots[index] = booked;
    _myAppointments.add(booked);
    return booked;
  }

  /// Tele appointments are booked by phone call to the health center, not
  /// through the slot list — Phase 3 §3.1/§4.1. A staff member calls back
  /// to confirm; this simulates that outcome landing directly in "my
  /// appointments" a moment later.
  Future<Appointment> bookTeleAppointment() async {
    await Future.delayed(const Duration(milliseconds: 700));
    _teleCounter++;
    final booked = Appointment(
      id: 'tele_$_teleCounter',
      centerName: 'Naim Health Center',
      doctorName: 'Dr. Hind Al-Zayani',
      slotDateTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
      status: 'confirmed',
      isTele: true,
    );
    _myAppointments.add(booked);
    return booked;
  }

  /// GET my appointments list
  Future<List<Appointment>> getMyAppointments() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_myAppointments);
  }

  /// PUT/DELETE /api/v1/appointments/{id} — cancel
  Future<void> cancelAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _myAppointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _myAppointments[index] = _myAppointments[index].copyWith(
        status: 'cancelled',
      );
    }
  }
}
