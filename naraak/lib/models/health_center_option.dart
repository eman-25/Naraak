/// A selectable health center and the family doctors currently accepting
/// transfers there. Backs the "Change Family Doctor" flow (Phase 3 §3.x) —
/// an empty [doctors] list is intentional demo data used to exercise the
/// "no doctors available at this center" decision point.
class HealthCenterOption {
  final String name;
  final List<String> doctors;

  const HealthCenterOption({required this.name, required this.doctors});
}
