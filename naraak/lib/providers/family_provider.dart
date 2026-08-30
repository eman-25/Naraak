import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/family_member.dart';

class FamilyProvider extends ChangeNotifier {
  FamilyProvider(this.repository);
  final NaraakRepository repository;
  final List<FamilyMember> _members = [];
  List<FamilyMember> get members => List.unmodifiable(_members);
  String? errorMessage;

  Future<bool> loadMembers() async {
    try {
      final profile = await repository.profile();
      final center = Map<String, dynamic>.from(profile['healthCenter'] as Map);
      final values = await repository.familyMembers();
      _members
        ..clear()
        ..add(FamilyMember(
            id: profile['patientId'] as String,
            fullName: profile['fullName'] as String,
            relation: 'Self',
            age: profile['age'] as int,
            cprMasked: _mask(profile['cpr'] as String),
            healthCenter: center['name'] as String,
            isActive: true))
        ..addAll(values.map((value) => FamilyMember(
            id: value['familyMemberId'] as String,
            fullName: value['fullName'] as String,
            relation: value['relationship'] as String,
            age: value['age'] as int,
            cprMasked: _mask(value['cpr'] as String),
            healthCenter: value['healthCenterId'] as String)));
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
      return false;
    }
  }

  String _mask(String cpr) => cpr.length < 5
      ? cpr
      : '${cpr.substring(0, 4)}•••${cpr.substring(cpr.length - 2)}';
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
