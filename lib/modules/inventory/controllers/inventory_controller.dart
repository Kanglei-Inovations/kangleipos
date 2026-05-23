import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';

class InventoryController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  // State
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Brand> brands = <Brand>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryId = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final pList = await db.select(db.products).get();
      final cList = await db.select(db.categories).get();
      final bList = await db.select(db.brands).get();
      
      products.assignAll(pList);
      categories.assignAll(cList);
      brands.assignAll(bList);
    } finally {
      isLoading.value = false;
    }
  }

  // SEARCH & FILTER
  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
                           (p.barcode?.contains(searchQuery.value) ?? false) ||
                           (p.sku?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      final matchesCategory = selectedCategoryId.value == 'All' || p.categoryId == selectedCategoryId.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // METRICS
  int get totalProducts => products.length;
  
  double get totalStock => products.fold(0.0, (sum, p) => sum + p.stockQuantity);
  
  int get lowStockCount => products.where((p) => p.stockQuantity <= p.lowStockAlert && p.stockQuantity > 0).length;
  
  int get outOfStockCount => products.where((p) => p.stockQuantity <= 0).length;
  
  double get totalStockValue => products.fold(0.0, (sum, p) => sum + (p.stockQuantity * (p.costPrice ?? 0.0)));

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (var p in products) {
      final catName = categories.firstWhereOrNull((c) => c.id == p.categoryId)?.name ?? 'Others';
      counts[catName] = (counts[catName] ?? 0) + 1;
    }
    return counts;
  }

  List<Product> get lowStockProducts => products.where((p) => p.stockQuantity <= p.lowStockAlert).toList();

  // CRUD OPERATIONS
  Future<void> addProduct(ProductsCompanion entry) async {
    final id = _uuid.v4();
    await db.into(db.products).insert(entry.copyWith(id: d.Value(id)));
    await refreshData();
  }

  Future<void> updateProduct(Product product) async {
    await db.update(db.products).replace(product);
    await refreshData();
  }

  Future<void> deleteProduct(String id) async {
    await (db.delete(db.products)..where((t) => t.id.equals(id))).go();
    await refreshData();
  }

  // CATEGORY & BRAND HELPERS
  Future<void> addCategory(String name) async {
    final id = _uuid.v4();
    await db.into(db.categories).insert(CategoriesCompanion(
      id: d.Value(id),
      name: d.Value(name),
    ));
    await refreshData();
  }

  Future<void> addBrand(String name) async {
    final id = _uuid.v4();
    await db.into(db.brands).insert(BrandsCompanion(
      id: d.Value(id),
      name: d.Value(name),
    ));
    await refreshData();
  }
}
