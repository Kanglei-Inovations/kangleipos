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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Defensive migration: add columns individually and catch errors
          // if they already exist (common in development)
          final List<GeneratedColumn> newColumns = [
            products.sku,
            products.mrp,
            products.discountType,
            products.discountValue,
            products.trackInventory,
            products.reorderLevel,
            products.reorderQuantity,
            products.warehouse,
            products.taxClass,
            products.gstRate,
            products.images,
            products.description,
            products.warrantyPeriod,
            products.expiryPeriod,
            products.tags,
            products.status,
            products.updatedAt,
          ];

          for (final column in newColumns) {
            try {
              await m.addColumn(products, column);
            } catch (e) {
              // Ignore "duplicate column name" or other migration errors for specific columns
              print('Migration info: Column ${column.name} might already exist.');
            }
          }
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
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
