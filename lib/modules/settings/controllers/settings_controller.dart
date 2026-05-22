import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import '../../../core/services/preference_service.dart';

class SettingsController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final PreferenceService _prefs = Get.find<PreferenceService>();

  final RxString businessName = ''.obs;
  final RxString address = ''.obs;
  final RxString gst = ''.obs;
  final RxInt sessionTimeout = 15.obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final settings = await db.select(db.settings).get();
      
      businessName.value = settings.firstWhereOrNull((s) => s.key == 'business_name')?.value ?? '';
      address.value = settings.firstWhereOrNull((s) => s.key == 'business_address')?.value ?? '';
      gst.value = settings.firstWhereOrNull((s) => s.key == 'business_gst')?.value ?? '';
      
      sessionTimeout.value = _prefs.sessionTimeout;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings({
    required String name,
    required String addr,
    required String gstNo,
    required int timeout,
  }) async {
    isLoading.value = true;
    try {
      await (db.delete(db.settings)).go(); // Clear and rewrite for simplicity
      
      await db.into(db.settings).insert(SettingsCompanion(key: const d.Value('business_name'), value: d.Value(name)));
      await db.into(db.settings).insert(SettingsCompanion(key: const d.Value('business_address'), value: d.Value(addr)));
      await db.into(db.settings).insert(SettingsCompanion(key: const d.Value('business_gst'), value: d.Value(gstNo)));

      await _prefs.setSessionTimeout(timeout);
      
      businessName.value = name;
      address.value = addr;
      gst.value = gstNo;
      sessionTimeout.value = timeout;
      
      Get.snackbar('Success', 'Business settings updated.');
    } finally {
      isLoading.value = false;
    }
  }
}
