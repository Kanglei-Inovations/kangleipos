import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class BackupService {
  static Future<String?> createBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'printonex_erp', 'app_db.sqlite');
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        Get.snackbar('Error', 'Database file not found at $dbPath');
        return null;
      }

      final backupFolder = await getApplicationSupportDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final zipPath = p.join(backupFolder.path, 'kanglei_backup_$timestamp.zip');

      final encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addFile(dbFile);
      encoder.close();

      return zipPath;
    } catch (e) {
      Get.snackbar('Backup Failed', e.toString());
      return null;
    }
  }

  static Future<bool> restoreBackup(String zipPath) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'printonex_erp', 'app_db.sqlite');

      for (final file in archive) {
        if (file.isFile && file.name.endsWith('.sqlite')) {
          final data = file.content as List<int>;
          await File(dbPath).writeAsBytes(data);
          return true;
        }
      }
      return false;
    } catch (e) {
      Get.snackbar('Restore Failed', e.toString());
      return false;
    }
  }
}
