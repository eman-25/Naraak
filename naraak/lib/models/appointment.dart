// lib/models/appointment.dart
class Appointment {
  final String id;
  final String centerName;
  final String doctorName;
  final String? doctorGender; // 'Male' | 'Female'
  final DateTime slotDateTime;
  final String status; // 'available' | 'confirmed' | 'cancelled' | 'completed'
  final bool isTele;
  final String? clinic;
  final String? slotId;
  final String? endTime;

  const Appointment({
    required this.id,
    required this.centerName,
    required this.doctorName,
    this.doctorGender,
    required this.slotDateTime,
    required this.status,
    this.isTele = false,
    this.clinic,
    this.slotId,
    this.endTime,
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
      isTele: isTele,
      clinic: clinic,
      slotId: slotId,
      endTime: endTime,
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: (json['appointmentId'] ?? json['slotId'] ?? json['id']) as String,
      centerName: (json['healthCenter'] ?? json['centerName']) as String,
      doctorName: json['doctorName'] as String,
      doctorGender: json['doctorGender'] as String?,
      slotDateTime: json['date'] != null
          ? DateTime.parse("${json['date']}T${json['startTime']}:00")
          : DateTime.parse(json['slotDateTime'] as String),
      status: (json['status'] ??
          (json['available'] == true ? 'available' : 'confirmed')) as String,
      isTele: json['appointmentType'] != null
          ? json['appointmentType'] == 'tele'
          : json['isTele'] as bool? ?? false,
      clinic: json['clinic'] as String?,
      slotId: json['slotId'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'centerName': centerName,
        'doctorName': doctorName,
        'doctorGender': doctorGender,
        'slotDateTime': slotDateTime.toIso8601String(),
        'status': status,
        'isTele': isTele,
        'clinic': clinic,
        'slotId': slotId,
        'endTime': endTime,
      };
}
