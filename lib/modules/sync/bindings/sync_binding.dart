import 'package:get/get.dart';
import '../controllers/sync_controller.dart';
import '../../../sync/sync_server.dart';
import '../../../sync/sync_client.dart';

class SyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SyncServerService());
    Get.lazyPut(() => SyncClientService());
    Get.lazyPut(() => SyncController());
  }
}
