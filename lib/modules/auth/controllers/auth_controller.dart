import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import '../../../database/database.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final PreferenceService _prefs = Get.find<PreferenceService>();
  final _uuid = const Uuid();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  final RxString currentUserName = ''.obs;
  final RxString currentUserRole = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _checkInitialState();
  }

  void _checkInitialState() {
    if (!_prefs.isSetupComplete) {
      Get.offAllNamed(AppRoutes.SETUP);
    } else {
      _checkSession();
    }
  }

  void _checkSession() {
    final lastActive = _prefs.lastActivity;
    if (lastActive != null) {
      final difference = DateTime.now().difference(lastActive).inMinutes;
      if (difference < _prefs.sessionTimeout) {
        // Auto-login
        currentUserName.value = _prefs.authUserName ?? '';
        currentUserRole.value = _prefs.authUserRole ?? '';
        if (currentUserName.isNotEmpty) {
          _prefs.updateLastActivity();
          Get.offAllNamed(AppRoutes.DASHBOARD);
          return;
        }
      }
    }
    // Stay on login/PIN
  }

  String _hashSecret(String secret) {
    var bytes = utf8.encode(secret);
    return sha256.convert(bytes).toString();
  }

  // --- SETUP LOGIC ---
  Future<void> completeSetup({
    required String businessName,
    required String address,
    required String gst,
    required String adminName,
    required String adminPin,
    required int timeout,
  }) async {
    isLoading.value = true;
    try {
      // 1. Save Business Settings
      await db.into(db.settings).insert(SettingsCompanion(
          key: const d.Value('business_name'), value: d.Value(businessName)));
      await db.into(db.settings).insert(SettingsCompanion(
          key: const d.Value('business_address'), value: d.Value(address)));
      await db.into(db.settings).insert(SettingsCompanion(
          key: const d.Value('business_gst'), value: d.Value(gst)));

      // 2. Create Admin User
      final userId = _uuid.v4();
      await db.into(db.users).insert(UsersCompanion(
            id: d.Value(userId),
            name: d.Value(adminName),
            username: d.Value('admin'), // Default admin username
            passwordHash: d.Value(_hashSecret(
                adminPin)), // Using PIN as password for simplicity in local setup
            pin: d.Value(_hashSecret(adminPin)),
            role: const d.Value('ADMIN'),
          ));

      // 3. Save Preferences
      await _prefs.setSessionTimeout(timeout);
      await _prefs.setSetupComplete(true);
      await _prefs.saveSession(userId, adminName, 'ADMIN');

      currentUserName.value = adminName;
      currentUserRole.value = 'ADMIN';

      Get.offAllNamed(AppRoutes.DASHBOARD);
    } catch (e) {
      Get.snackbar('Setup Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIN LOGIC ---
  Future<void> loginWithPin(String pin) async {
    isLoading.value = true;
    try {
      final hashed = _hashSecret(pin);
      final user = await (db.select(db.users)
            ..where((u) => u.pin.equals(hashed)))
          .getSingleOrNull();

      if (user != null) {
        await _prefs.saveSession(user.id, user.name, user.role);
        currentUserName.value = user.name;
        currentUserRole.value = user.role;
        _prefs.updateLastActivity();
        Get.offAllNamed(
            user.role == 'ADMIN' ? AppRoutes.DASHBOARD : AppRoutes.POS);
      } else {
        Get.snackbar('Error', 'Invalid PIN');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithPassword({
    required String usernameOrEmail,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final normalized = usernameOrEmail.trim().toLowerCase();
      final username =
          normalized.contains('@') ? normalized.split('@').first : normalized;
      final hashed = _hashSecret(password);

      final user = await (db.select(db.users)
            ..where(
              (u) =>
                  u.username.equals(username) & u.passwordHash.equals(hashed),
            ))
          .getSingleOrNull();

      if (user != null) {
        await _prefs.saveSession(user.id, user.name, user.role);
        currentUserName.value = user.name;
        currentUserRole.value = user.role;
        _prefs.updateLastActivity();
        Get.offAllNamed(
            user.role == 'ADMIN' ? AppRoutes.DASHBOARD : AppRoutes.POS);
      } else {
        Get.snackbar('Error', 'Invalid username or password');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _prefs.clearSession();
    currentUserName.value = '';
    currentUserRole.value = '';
    Get.offAllNamed(AppRoutes.AUTH);
  }
}
