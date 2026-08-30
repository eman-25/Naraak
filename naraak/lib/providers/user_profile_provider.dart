import 'package:flutter/foundation.dart';
import '../data/naraak_repository.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider(this.repository);
  final NaraakRepository repository;
  UserProfile? _profile;
  String? _loggedInCpr;
  String? _errorMessage;
  bool _loading = false;
  UserProfile? get profile => _profile;
  String? get loggedInCpr => _loggedInCpr;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loading;
  bool get isLoggedIn => _loggedInCpr != null;
  bool get isProfileComplete => _profile != null;

  Future<bool> login(String cpr) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final auth = await repository.login();
      final user = Map<String, dynamic>.from(auth['user'] as Map);
      _loggedInCpr = cpr;
      _profile = _fromApi(user);
      _loading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    try {
      _profile = _fromApi(await repository.profile());
      notifyListeners();
    } catch (error) {
      _errorMessage = repository.friendlyError(error, arabic: false);
      notifyListeners();
    }
  }

  UserProfile _fromApi(Map<String, dynamic> value) {
    final center = Map<String, dynamic>.from(value['healthCenter'] as Map);
    final doctor = Map<String, dynamic>.from(value['familyDoctor'] as Map);
    return UserProfile(
        fullName: value['fullName'] as String,
        cpr: value['cpr'] as String,
        age: value['age'] as int,
        gender: value['gender'] as String,
        mobileNumber: value['phone'] as String,
        assignedHealthCenter: center['name'] as String,
        bloodType: value['bloodType'] as String?,
        familyDoctorName: doctor['doctorName'] as String?,
        familyDoctorSpecialty: doctor['specialty'] as String?);
  }

  void completeProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void switchDisplayName(String name) {
    if (_profile != null) {
      _profile = _profile!.copyWith(fullName: name);
      notifyListeners();
    }
  }

  void logout() {
    _loggedInCpr = null;
    _profile = null;
    repository.patientId = null;
    notifyListeners();
  }
}
