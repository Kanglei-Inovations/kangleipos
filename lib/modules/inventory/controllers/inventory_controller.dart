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
                           (p.barcode?.contains(searchQuery.value) ?? false);
      final matchesCategory = selectedCategoryId.value == 'All' || p.categoryId == selectedCategoryId.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

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
