/// Shaped to match the Phase 5 API spec for /api/v1/appointments,
/// so swapping the mock service for a real one later is mechanical.
class Appointment {
  final String id;
  final String centerName;
  final String doctorName;
  final DateTime slotDateTime;
  final String status; // 'available' | 'confirmed' | 'cancelled' | 'completed'
  final bool isTele;

  const Appointment({
    required this.id,
    required this.centerName,
    required this.doctorName,
    required this.slotDateTime,
    required this.status,
    this.isTele = false,
  });

  Appointment copyWith({String? status}) {
    return Appointment(
      id: id,
      centerName: centerName,
      doctorName: doctorName,
      slotDateTime: slotDateTime,
      status: status ?? this.status,
      isTele: isTele,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      centerName: json['centerName'] as String,
      doctorName: json['doctorName'] as String,
      slotDateTime: DateTime.parse(json['slotDateTime'] as String),
      status: json['status'] as String,
      isTele: json['isTele'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'centerName': centerName,
        'doctorName': doctorName,
        'slotDateTime': slotDateTime.toIso8601String(),
        'status': status,
        'isTele': isTele,
      };
}
