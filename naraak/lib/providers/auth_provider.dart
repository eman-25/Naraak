// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String roleLabel;

  const UserProfile({
    required this.id,
    required this.name,
    required this.roleLabel,
  });

  /// Keep avatar text derived from the account name so it never becomes
  /// stale when an account name is updated.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final words = parts.toList();
    if (words.isEmpty) return '?';
    return (words.length == 1 ? words.first[0] : '${words.first[0]}${words.last[0]}')
        .toUpperCase();
  }
}

class AuthProvider extends ChangeNotifier {
  UserProfile _currentUser = const UserProfile(
    id: '1',
    name: 'Ebrahim Khalil',
    roleLabel: 'Patient',
  );

  final List<UserProfile> _availableUsers = const [
    UserProfile(
      id: '1',
      name: 'Ebrahim Khalil',
      roleLabel: 'Patient',
    ),
    UserProfile(
      id: '2',
      name: 'Sara Ahmed',
      roleLabel: 'Dependent (Daughter)',
    ),
    UserProfile(
      id: '3',
      name: 'Ali Khalil',
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
