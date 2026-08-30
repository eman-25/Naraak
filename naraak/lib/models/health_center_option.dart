/// A family doctor available at a health center for a "Change Family
/// Doctor" transfer request. Phase 3 §29 requires the doctor card to show
/// name, gender, specialty, health center and available quota, and to
/// surface a distinct "no available capacity" state rather than hiding
/// doctors with no quota.
class FamilyDoctorOption {
  final String doctorId;
  final String name;
  final String gender;
  final String specialty;
  final bool capacityAvailable;
  final int availableQuota;

  const FamilyDoctorOption({
    required this.doctorId,
    required this.name,
    required this.gender,
    required this.specialty,
    required this.capacityAvailable,
    required this.availableQuota,
  });
}

/// A selectable health center and the family doctors at it. An empty
/// [doctors] list is intentional demo data used to exercise the "no
/// doctors available at this center" decision point.
class HealthCenterOption {
  final String name;
  final List<FamilyDoctorOption> doctors;

  const HealthCenterOption({required this.name, required this.doctors});
}
