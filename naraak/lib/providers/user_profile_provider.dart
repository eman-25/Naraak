import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Holds the logged-in user's profile in memory for this session.
/// isProfileComplete gates whether the app shows the setup form or
/// goes straight to the main app after login.
class UserProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  String? _loggedInCpr;

  UserProfile? get profile => _profile;
  String? get loggedInCpr => _loggedInCpr;
  bool get isLoggedIn => _loggedInCpr != null;
  bool get isProfileComplete => _profile != null;

  void login(String cpr) {
    _loggedInCpr = cpr;
    notifyListeners();
  }

  void completeProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void logout() {
    _loggedInCpr = null;
    _profile = null;
    notifyListeners();
  }
}