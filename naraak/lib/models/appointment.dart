// lib/models/appointment.dart
class Appointment {
  final String id;
  final String centerName;
  final String doctorName;
  final String? doctorGender; // 'Male' | 'Female'
  final DateTime slotDateTime;
  final String status; // 'available' | 'confirmed' | 'cancelled' | 'completed'

  const Appointment({
    required this.id,
    required this.centerName,
    required this.doctorName,
    this.doctorGender,
    required this.slotDateTime,
    required this.status,
  });

  Appointment copyWith({
    String? id,
    String? centerName,
    String? doctorName,
    String? doctorGender,
    DateTime? slotDateTime,
    String? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      centerName: centerName ?? this.centerName,
      doctorName: doctorName ?? this.doctorName,
      doctorGender: doctorGender ?? this.doctorGender,
      slotDateTime: slotDateTime ?? this.slotDateTime,
      status: status ?? this.status,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      centerName: json['centerName'] as String,
      doctorName: json['doctorName'] as String,
      doctorGender: json['doctorGender'] as String?,
      slotDateTime: DateTime.parse(json['slotDateTime'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'centerName': centerName,
        'doctorName': doctorName,
        'doctorGender': doctorGender,
        'slotDateTime': slotDateTime.toIso8601String(),
        'status': status,
      };
}