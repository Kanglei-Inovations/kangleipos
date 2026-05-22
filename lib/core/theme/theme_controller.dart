import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/preference_service.dart';

class AppThemeController extends ChangeNotifier {
  final PreferenceService _prefs = Get.find<PreferenceService>();
  ThemeMode _themeMode = ThemeMode.light;

  AppThemeController() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadThemeMode() {
    final savedMode = _prefs.themeMode;
    if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _prefs.setThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs.setThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
