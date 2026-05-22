import 'package:get/get.dart';
import '../../../services/backup_service.dart';

class BackupController extends GetxController {
  final RxBool isProcessing = false.obs;
  final RxString lastBackupPath = ''.obs;

  Future<void> runBackup() async {
    isProcessing.value = true;
    final path = await BackupService.createBackup();
    isProcessing.value = false;
    
    if (path != null) {
      lastBackupPath.value = path;
      Get.snackbar('Success', 'Backup created at: $path', duration: const Duration(seconds: 5));
    }
  }

  // TODO: Add file picker for restore
}
