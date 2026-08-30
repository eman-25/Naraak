import '../api/naraak_api.dart';

/// Application data gateway. Providers depend on this abstraction so the
/// dummy client can later be replaced without changing presentation code.
class NaraakRepository {
  NaraakRepository({NaraakDummyApi? api}) : api = api ?? NaraakDummyApi();

  final NaraakDummyApi api;
  String? patientId;

  dynamic data(Map<String, dynamic> response) => response['data'];

  Future<Map<String, dynamic>> login() async {
    final value =
        Map<String, dynamic>.from(data(await api.simulateEkeyLogin()) as Map);
    final user = Map<String, dynamic>.from(value['user'] as Map);
    patientId = user['patientId'] as String;
    return value;
  }

  Future<Map<String, dynamic>> profile() async =>
      Map<String, dynamic>.from(data(await api.getProfile()) as Map);

  Future<Map<String, dynamic>> dashboard() async =>
      Map<String, dynamic>.from(data(await api.getHomeDashboard()) as Map);

  Future<List<Map<String, dynamic>>> familyMembers() async =>
      _list(await api.getFamilyMembers());

  String get requirePatientId => patientId ?? 'PAT-001';

  List<Map<String, dynamic>> _list(Map<String, dynamic> response) =>
      (data(response) as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  String friendlyError(Object error, {required bool arabic}) {
    if (error is! NaraakApiException) {
      return arabic
          ? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'
          : 'Something went wrong. Please try again.';
    }
    if (arabic) {
      return switch (error.statusCode) {
        400 => 'يرجى التحقق من البيانات المطلوبة والمحاولة مرة أخرى.',
        401 => 'تعذر تسجيل الدخول. يرجى التحقق من صلاحية البطاقة السكانية.',
        404 => 'لم نتمكن من العثور على البيانات المطلوبة.',
        409 => 'لم يعد الخيار المحدد متاحاً. يرجى اختيار خيار آخر.',
        _ => 'تعذر إكمال الطلب. يرجى المحاولة مرة أخرى.',
      };
    }
    return switch (error.statusCode) {
      400 => 'Please check the required information and try again.',
      401 => 'Sign in failed. Please check that your CPR is valid.',
      404 => 'The requested information could not be found.',
      409 => 'That option is no longer available. Please choose another.',
      _ => 'We could not complete your request. Please try again.',
    };
  }
}
