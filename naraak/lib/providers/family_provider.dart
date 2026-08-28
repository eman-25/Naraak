// lib/providers/family_provider.dart
import 'package:flutter/foundation.dart';
import '../models/family_member.dart';

/// In-memory family list per Phase 3 §2.6 (Family Management: add or
/// select existing, act on their behalf). Dummy data only — SCOPE LIMIT.
class FamilyProvider extends ChangeNotifier {
  final List<FamilyMember> _members = [
    const FamilyMember(id: 'm1', fullName: 'Eman Al-Khalifa', relation: 'Self', age: 36, cprMasked: '8701•••23', healthCenter: 'Hoora PHC — Manama', isActive: true),
    const FamilyMember(id: 'm2', fullName: 'Yousif Al-Khalifa', relation: 'Spouse', age: 38, cprMasked: '8503•••77', healthCenter: 'Hoora PHC — Manama'),
    const FamilyMember(id: 'm3', fullName: 'Layla Al-Khalifa', relation: 'Child', age: 5, cprMasked: '2101•••07', healthCenter: 'Hoora PHC — Manama'),
    const FamilyMember(id: 'm4', fullName: 'Ahmed Al-Khalifa', relation: 'Parent', age: 71, cprMasked: '5506•••90', healthCenter: 'Naim PHC — Manama'),
  ];

  List<FamilyMember> get members => List.unmodifiable(_members);

  void setActive(String id) {
    for (var i = 0; i < _members.length; i++) {
      _members[i] = _members[i].copyWith(isActive: _members[i].id == id);
    }
    notifyListeners();
  }

  void addMember(FamilyMember member) {
    _members.add(member);
    notifyListeners();
  }
}