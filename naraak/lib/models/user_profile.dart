/// Holds the data the user enters at login/setup time — replaces the
/// hardcoded demo values previously shown on Home/Profile screens.
class UserProfile {
  final String fullName;
  final String cpr;
  final int age;
  final String gender; // 'Male' | 'Female'
  final String mobileNumber;
  final String assignedHealthCenter;

  const UserProfile({
    required this.fullName,
    required this.cpr,
    required this.age,
    required this.gender,
    required this.mobileNumber,
    required this.assignedHealthCenter,
  });

  UserProfile copyWith({
    String? fullName,
    String? cpr,
    int? age,
    String? gender,
    String? mobileNumber,
    String? assignedHealthCenter,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      cpr: cpr ?? this.cpr,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      assignedHealthCenter: assignedHealthCenter ?? this.assignedHealthCenter,
    );
  }
}