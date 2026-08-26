/// A completed Hajj trip on record for the logged-in CPR, matched by Hijri
/// year. Backs the eligibility check in the Electronic Hajj Certificate
/// flow (Phase 3 §3.x) — a lookup that returns null represents the
/// "no record found for that year" decision point.
class HajjTripRecord {
  final int hijriYear;
  final String operatorName;
  final String groupNumber;

  const HajjTripRecord({
    required this.hijriYear,
    required this.operatorName,
    required this.groupNumber,
  });
}
