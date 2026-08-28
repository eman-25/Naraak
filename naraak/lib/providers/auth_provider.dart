// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String initials;
  final String roleLabel;

  const UserProfile({
    required this.id,
    required this.name,
    required this.initials,
    required this.roleLabel,
  });
}

class AuthProvider extends ChangeNotifier {
  UserProfile _currentUser = const UserProfile(
    id: '1',
    name: 'Ebrahim Khalil',
    initials: 'EK',
    roleLabel: 'Patient',
  );

  final List<UserProfile> _availableUsers = const [
    UserProfile(
      id: '1',
      name: 'Ebrahim Khalil',
      initials: 'EK',
      roleLabel: 'Patient',
    ),
    UserProfile(
      id: '2',
      name: 'Sara Ahmed',
      initials: 'SA',
      roleLabel: 'Dependent (Daughter)',
    ),
    UserProfile(
      id: '3',
      name: 'Ali Khalil',
      initials: 'AK',
      roleLabel: 'Dependent (Son)',
    ),
  ];

  UserProfile get currentUser => _currentUser;
  List<UserProfile> get availableUsers => _availableUsers;

  void switchUser(String userId) {
    final selected = _availableUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () => _currentUser,
    );
    _currentUser = selected;
    notifyListeners();
  }
}