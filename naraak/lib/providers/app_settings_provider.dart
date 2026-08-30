// lib/providers/app_settings_provider.dart
import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

class AppSettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  AppPaletteId _paletteId = AppPaletteId.healthcareTeal;
  double _textScale = 1.0;

  static const minScale = 0.8;
  static const maxScale = 1.3;
  static const _step = 0.05;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  AppPaletteId get paletteId => _paletteId;
  AppPalette get palette => AppPalette.fromId(_paletteId);
  double get textScale => _textScale;
  int get textScalePercent => (_textScale * 100).round();

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocaleFromApiLanguage(String? languageCode) {
    if (languageCode != 'ar' && languageCode != 'en') return;
    setLocale(Locale(languageCode!));
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setPalette(AppPaletteId id) {
    _paletteId = id;
    notifyListeners();
  }

  void increaseTextSize() {
    _textScale = (_textScale + _step).clamp(minScale, maxScale);
    notifyListeners();
  }

  void decreaseTextSize() {
    _textScale = (_textScale - _step).clamp(minScale, maxScale);
    notifyListeners();
  }

  void resetTextSize() {
    _textScale = 1.0;
    notifyListeners();
  }

  void setTextSize(double value) {
    _textScale = value.clamp(minScale, maxScale);
    notifyListeners();
  }
}
