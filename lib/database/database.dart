import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users, Categories, Brands, Products, Customers, Suppliers, Invoices, InvoiceItems, Purchases, Expenses, Settings
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'printonex_erp', 'app_db.sqlite'));
    
    // Make sure the directory exists
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    return NativeDatabase.createInBackground(file);
  });
}
