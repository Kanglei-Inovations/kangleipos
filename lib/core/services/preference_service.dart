import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _keyIsSetupComplete = 'is_setup_complete';
  static const String _keySessionTimeout = 'session_timeout_mins';
  static const String _keyLastActivity = 'last_activity_timestamp';
  static const String _keyAuthUserId = 'auth_user_id';
  static const String _keyAuthUserName = 'auth_user_name';
  static const String _keyAuthUserRole = 'auth_user_role';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyWindowWidth = 'window_width';
  static const String _keyWindowHeight = 'window_height';

  late SharedPreferences _prefs;

  Future<PreferenceService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  bool get isSetupComplete => _prefs.getBool(_keyIsSetupComplete) ?? false;
  Future<void> setSetupComplete(bool value) => _prefs.setBool(_keyIsSetupComplete, value);

  int get sessionTimeout => _prefs.getInt(_keySessionTimeout) ?? 15; // default 15 mins
  Future<void> setSessionTimeout(int mins) => _prefs.setInt(_keySessionTimeout, mins);

  DateTime? get lastActivity {
    final timestamp = _prefs.getInt(_keyLastActivity);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  Future<void> updateLastActivity() => _prefs.setInt(_keyLastActivity, DateTime.now().millisecondsSinceEpoch);

  String? get authUserId => _prefs.getString(_keyAuthUserId);
  String? get authUserName => _prefs.getString(_keyAuthUserName);
  String? get authUserRole => _prefs.getString(_keyAuthUserRole);

  Future<void> saveSession(String id, String name, String role) async {
    await _prefs.setString(_keyAuthUserId, id);
    await _prefs.setString(_keyAuthAuthUserName, name);
    await _prefs.setString(_keyAuthUserRole, role);
    await updateLastActivity();
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyAuthUserId);
    await _prefs.remove(_keyAuthUserName);
    await _prefs.remove(_keyAuthUserRole);
    await _prefs.remove(_keyLastActivity);
  }

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'light';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  double get windowWidth => _prefs.getDouble(_keyWindowWidth) ?? 1920.0;
  Future<void> setWindowWidth(double value) => _prefs.setDouble(_keyWindowWidth, value);

  double get windowHeight => _prefs.getDouble(_keyWindowHeight) ?? 1080.0;
  Future<void> setWindowHeight(double value) => _prefs.setDouble(_keyWindowHeight, value);

  // Helper to fix the typo I made in my head just now
  static const String _keyAuthAuthUserName = 'auth_user_name';
}
