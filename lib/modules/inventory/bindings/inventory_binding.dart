import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';
import '../../../database/database.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure Database is initialized and available
    if (!Get.isRegistered<AppDatabase>()) {
      Get.put(AppDatabase(), permanent: true);
    }
    
    Get.lazyPut<InventoryController>(
      () => InventoryController(),
    );
  }
}
