import 'package:get/get.dart';
import '../controllers/products_master_controller.dart';

class ProductsMasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsMasterController>(() => ProductsMasterController());
  }
}
