import 'package:flutter/material.dart';
import '../data/naraak_repository.dart';

class UserProfile {
  final String id;
  final String name;
  final String roleLabel;
  const UserProfile(
      {required this.id, required this.name, required this.roleLabel});
  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return (words.length == 1
            ? words.first[0]
            : '${words.first[0]}${words.last[0]}')
        .toUpperCase();
  }
}

class AuthProvider extends ChangeNotifier {
  AuthProvider(this.repository);
  final NaraakRepository repository;
  UserProfile _currentUser =
      const UserProfile(id: '', name: '', roleLabel: 'Patient');
  final List<UserProfile> _availableUsers = [];
  UserProfile get currentUser => _currentUser;
  List<UserProfile> get availableUsers => List.unmodifiable(_availableUsers);
  String? errorMessage;

  Future<bool> loadUsers() async {
    try {
      final profile = await repository.profile();
      final family = await repository.familyMembers();
      _availableUsers
        ..clear()
        ..add(UserProfile(
            id: profile['patientId'] as String,
            name: profile['fullName'] as String,
            roleLabel: 'Patient'))
        ..addAll(family.map((item) => UserProfile(
            id: item['patientId'] as String,
            name: item['fullName'] as String,
            roleLabel: 'Dependent (${item['relationship']})')));
      _currentUser = _availableUsers.first;
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
      return false;
    }
  }

  void switchUser(String userId) {
    final matches = _availableUsers.where((u) => u.id == userId);
    if (matches.isNotEmpty) {
      _currentUser = matches.first;
      repository.patientId = userId;
      notifyListeners();
    }
  }
}
