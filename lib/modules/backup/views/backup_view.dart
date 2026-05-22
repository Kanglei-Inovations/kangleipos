import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Backup & Restore',
      child: Center(
        child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text('Secure Local Backup', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Create an encrypted ZIP backup of your entire database. You can save this to a pendrive or external drive for safety.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: controller.isProcessing.value ? null : () => controller.runBackup(),
                  icon: controller.isProcessing.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.backup),
                  label: const Text('CREATE BACKUP NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.restore),
                label: const Text('RESTORE FROM FILE'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => controller.lastBackupPath.isNotEmpty 
                ? Text('Last backup: ${controller.lastBackupPath.value.split('\\').last}', style: const TextStyle(fontSize: 10, color: Colors.grey))
                : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
