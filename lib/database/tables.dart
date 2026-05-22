import 'package:drift/drift.dart';

// --- AUTH & USERS ---
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get pin => text().nullable()(); // For PIN lock
  TextColumn get role => text().withDefault(const Constant('CASHIER'))(); // ADMIN, MANAGER, CASHIER
  BoolColumn get fingerprintEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- PRODUCT & INVENTORY ---
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  @override Set<Column> get primaryKey => {id};
}

class Brands extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  @override Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get barcode => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get brandId => text().nullable().references(Brands, #id)();
  RealColumn get price => real()(); // Selling price
  RealColumn get costPrice => real().nullable()(); // Purchase price
  RealColumn get stockQuantity => real().withDefault(const Constant(0.0))();
  RealColumn get lowStockAlert => real().withDefault(const Constant(5.0))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  TextColumn get hsnSac => text().nullable()(); // GST support
  RealColumn get gstRate => real().withDefault(const Constant(0.0))(); // 0, 5, 12, 18, 28
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- CUSTOMERS ---
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get gstNumber => text().nullable()();
  RealColumn get balanceDue => real().withDefault(const Constant(0.0))();
  RealColumn get creditLimit => real().withDefault(const Constant(0.0))();
  RealColumn get loyaltyPoints => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- SUPPLIERS ---
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get gstNumber => text().nullable()();
  RealColumn get balanceDue => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- POS / INVOICES (SALES) ---
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().unique()();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get cashierId => text().nullable().references(Users, #id)();
  RealColumn get subtotal => real()();
  RealColumn get taxTotal => real().withDefault(const Constant(0.0))();
  RealColumn get cgstTotal => real().withDefault(const Constant(0.0))();
  RealColumn get sgstTotal => real().withDefault(const Constant(0.0))();
  RealColumn get igstTotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountTotal => real().withDefault(const Constant(0.0))();
  RealColumn get grandTotal => real()();
  TextColumn get status => text().withDefault(const Constant('PAID'))(); // PAID, UNPAID, HOLD, RETURNED
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))(); // CASH, CARD, UPI, SPLIT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get subtotal => real()();
  RealColumn get gstRate => real().withDefault(const Constant(0.0))();
  RealColumn get gstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// --- PURCHASES ---
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseNumber => text().unique()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  RealColumn get grandTotal => real()();
  TextColumn get status => text().withDefault(const Constant('RECEIVED'))();
  DateTimeColumn get purchaseDate => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- EXPENSES ---
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()(); // UTILITY, SALARY, PETTY_CASH
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get loggedBy => text().references(Users, #id)();
  DateTimeColumn get expenseDate => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- SYSTEM SETTINGS ---
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
