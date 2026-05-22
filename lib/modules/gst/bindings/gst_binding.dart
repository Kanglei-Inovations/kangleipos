import 'package:get/get.dart';
import '../controllers/gst_controller.dart';

class GstBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GstController>(() => GstController());
  }
}
