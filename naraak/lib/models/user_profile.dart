// lib/models/user_profile.dart
class UserProfile {
  final String fullName;
  final String cpr;
  final int age;
  final String gender;
  final String mobileNumber;
  final String assignedHealthCenter;
  final String? bloodType; // NEW — Phase 3 §2.1: "Profile: ... blood type"
  final String? nationality; // NEW — "other details"
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? familyDoctorName;
  final String? familyDoctorSpecialty;

  const UserProfile({
    required this.fullName,
    required this.cpr,
    required this.age,
    required this.gender,
    required this.mobileNumber,
    required this.assignedHealthCenter,
    this.bloodType,
    this.nationality,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.familyDoctorName,
    this.familyDoctorSpecialty,
  });

  UserProfile copyWith({
    String? fullName,
    String? cpr,
    int? age,
    String? gender,
    String? mobileNumber,
    String? assignedHealthCenter,
    String? bloodType,
    String? nationality,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? familyDoctorName,
    String? familyDoctorSpecialty,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      cpr: cpr ?? this.cpr,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      assignedHealthCenter: assignedHealthCenter ?? this.assignedHealthCenter,
      bloodType: bloodType ?? this.bloodType,
      nationality: nationality ?? this.nationality,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      familyDoctorName: familyDoctorName ?? this.familyDoctorName,
      familyDoctorSpecialty:
          familyDoctorSpecialty ?? this.familyDoctorSpecialty,
    );
  }
}
