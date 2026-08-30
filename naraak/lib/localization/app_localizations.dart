import 'package:flutter/material.dart';

/// Lightweight, app-wide copy catalog. Entries are UTF-8 source text so
/// Arabic renders correctly rather than as mojibake.
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const _values = <String, Map<String, String>>{
    'en': {
      'appName': 'Naraak',
      'home': 'Home', 'services': 'Services', 'appointments': 'Appointments',
      'profile': 'Profile', 'welcome': 'Welcome back',
      'healthCenter': 'My health center', 'upcoming': 'Upcoming appointment',
      'notifications': 'Notifications', 'higherPriority': 'Quick access',
      'moreServices': 'More services', 'settings': 'Settings',
      'darkMode': 'Dark mode', 'arabic': 'Arabic', 'english': 'English',
      'logout': 'Log out', 'externalApiTitle': 'External API required',
      'externalApiMessage': 'This service requires an external API to operate. The interface is ready, but connect the service API to enable live requests.',
      'close': 'Close', 'startService': 'Start Service', 'guest': 'Guest',
      'notSet': 'Not set', 'cpr': 'CPR', 'booking': 'Booking Appointments',
      'medicalReports': 'Medical Reports & Certificates',
      'teleAppointment': 'Tele-Appointment Instructions',
      'changeDoctor': 'Change Family Doctor', 'addressUpdate': 'Update Residential Address',
      'vaccinations': 'Vaccination Records & Certificate',
      'hajj': 'Electronic Hajj Certificate', 'feeExemption': 'Health Fee Exemption Card',
      'mobileUnit': 'Request Mobile Unit Service', 'mammogram': 'Mammogram Appointment Requests',
      'newborn': 'Sehati Card for Newborns', 'research': 'PHC Research Applications',
      'appearance': 'Appearance',
      'appearanceDescription': 'Pick a colour theme, mode, language and text size.',
      'colourTheme': 'Colour theme', 'language': 'Language', 'textSize': 'Text size',
      'active': 'Active', 'toggleDarkMode': 'Toggle dark mode',
      'readScreenAloud': 'Read screen aloud',
      'screenReaderAnnounced': 'Screen reader announced (demo).',
      'screenReaderMessage': 'Screen reader activated for this demo.',
      'switchAccount': 'Switch account', 'organizeFamilyMembers': 'Organize Family Members',
    },
    'ar': {
      'appName': 'نرعاك',
      'home': 'الرئيسية', 'services': 'الخدمات', 'appointments': 'المواعيد',
      'profile': 'الملف الشخصي', 'welcome': 'مرحباً بعودتك',
      'healthCenter': 'مركز الرعاية الصحية', 'upcoming': 'الموعد القادم',
      'notifications': 'التنبيهات', 'higherPriority': 'الوصول السريع',
      'moreServices': 'المزيد من الخدمات', 'settings': 'الإعدادات',
      'darkMode': 'الوضع الداكن', 'arabic': 'العربية', 'english': 'English',
      'logout': 'تسجيل الخروج', 'externalApiTitle': 'يتطلب اتصالاً خارجياً',
      'externalApiMessage': 'تتطلب هذه الخدمة واجهة API خارجية للعمل. الواجهة جاهزة، ولكن يجب ربط الخدمة لتفعيل الطلبات الفعلية.',
      'close': 'إغلاق', 'startService': 'بدء الخدمة', 'guest': 'زائر',
      'notSet': 'غير محدد', 'cpr': 'الرقم الشخصي', 'booking': 'حجز المواعيد',
      'medicalReports': 'التقارير والشهادات الطبية',
      'teleAppointment': 'تعليمات الموعد عن بُعد', 'changeDoctor': 'تغيير طبيب العائلة',
      'addressUpdate': 'تحديث عنوان السكن', 'vaccinations': 'سجل وشهادة التطعيمات',
      'hajj': 'شهادة الحج الإلكترونية', 'feeExemption': 'بطاقة الإعفاء من الرسوم الصحية',
      'mobileUnit': 'طلب خدمة الوحدة المتنقلة', 'mammogram': 'طلبات مواعيد فحص الثدي',
      'newborn': 'بطاقة صحتي لحديثي الولادة', 'research': 'طلبات أبحاث الرعاية الأولية',
      'appearance': 'المظهر', 'appearanceDescription': 'اختر السمة واللغة وحجم النص.',
      'colourTheme': 'سمة الألوان', 'language': 'اللغة', 'textSize': 'حجم النص',
      'active': 'نشط', 'toggleDarkMode': 'تبديل الوضع الداكن',
      'readScreenAloud': 'قراءة الشاشة بصوت عالٍ',
      'screenReaderAnnounced': 'تم الإعلان عبر قارئ الشاشة (تجريبي).',
      'screenReaderMessage': 'تم تشغيل قارئ الشاشة في هذا العرض التجريبي.',
      'switchAccount': 'تبديل الحساب', 'organizeFamilyMembers': 'تنظيم أفراد العائلة',
    },
  };

  String text(String key) => _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
