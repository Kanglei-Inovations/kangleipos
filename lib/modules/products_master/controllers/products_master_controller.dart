import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../database/database.dart';

class ProductsMasterController extends GetxController with GetSingleTickerProviderStateMixin {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();
  
  final RxInt selectedTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  // Master Data
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Brand> brands = <Brand>[].obs;
  
  // Summary Stats
  final RxInt totalProductsCount = 0.obs;
  final RxInt categoriesCount = 0.obs;
  final RxInt brandsCount = 0.obs;
  final RxInt unitsCount = 18.obs; 

  // Dummy data for demo if DB is empty
  final List<Map<String, String>> dummyUnits = [
    {'name': 'Pieces', 'abbr': 'pcs', 'type': 'Base Unit', 'status': 'Active'},
    {'name': 'Kilograms', 'abbr': 'kg', 'type': 'Weight Unit', 'status': 'Active'},
    {'name': 'Box (12)', 'abbr': 'box', 'type': 'Large Packing', 'status': 'Active'},
    {'name': 'Grams', 'abbr': 'g', 'type': 'Small Packing', 'status': 'Active'},
  ];

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    isLoading.value = true;
    try {
      final p = await db.select(db.products).get();
      final c = await db.select(db.categories).get();
      final b = await db.select(db.brands).get();
      
      products.assignAll(p);
      categories.assignAll(c);
      brands.assignAll(b);
      
      totalProductsCount.value = p.length;
      categoriesCount.value = c.length;
      brandsCount.value = b.length;
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String val) {
    searchQuery.value = val;
  }

  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) return products;
    final q = searchQuery.value.toLowerCase();
    return products.where((p) => p.name.toLowerCase().contains(q) || (p.barcode?.contains(q) ?? false)).toList();
  }
  
  List<Category> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    final q = searchQuery.value.toLowerCase();
    return categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<Brand> get filteredBrands {
    if (searchQuery.isEmpty) return brands;
    final q = searchQuery.value.toLowerCase();
    return brands.where((b) => b.name.toLowerCase().contains(q)).toList();
  }

  String generateId() => _uuid.v4();
}
