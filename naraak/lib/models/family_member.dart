// lib/models/family_member.dart
class FamilyMember {
  final String id;
  final String fullName;
  final String relation; // Self | Spouse | Child | Parent
  final int age;
  final String cprMasked;
  final String healthCenter;
  final bool isActive;

  const FamilyMember({
    required this.id,
    required this.fullName,
    required this.relation,
    required this.age,
    required this.cprMasked,
    required this.healthCenter,
    this.isActive = false,
  });

  FamilyMember copyWith({bool? isActive}) => FamilyMember(
        id: id,
        fullName: fullName,
        relation: relation,
        age: age,
        cprMasked: cprMasked,
        healthCenter: healthCenter,
        isActive: isActive ?? this.isActive,
      );

  String get initials {
    final parts = fullName.trim().split(' ');
    return parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : fullName[0].toUpperCase();
  }
}