import 'package:get/get.dart';
import '../../../database/database.dart';

class ProductsMasterController extends GetxController with GetSingleTickerProviderStateMixin {
  final AppDatabase db = Get.find<AppDatabase>();
  
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
  final RxInt unitsCount = 18.obs; // Dummy as units table not in DB yet

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
    return products.where((p) => p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || (p.barcode?.contains(searchQuery.value) ?? false)).toList();
  }
  
  List<Category> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    return categories.where((c) => c.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }

  List<Brand> get filteredBrands {
    if (searchQuery.isEmpty) return brands;
    return brands.where((b) => b.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }
}
