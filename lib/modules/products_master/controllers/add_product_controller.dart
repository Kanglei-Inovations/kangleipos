import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'products_master_controller.dart';

class AddProductController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  final formKey = GlobalKey<FormState>();

  // Form Fields
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final hsnController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final costPriceController = TextEditingController(text: '0.00');
  final sellingPriceController = TextEditingController(text: '0.00');
  final mrpController = TextEditingController(text: '0.00');
  final discountValueController = TextEditingController(text: '0.00');
  
  final openingStockController = TextEditingController(text: '0');
  final reorderLevelController = TextEditingController(text: '5');
  final reorderQuantityController = TextEditingController(text: '10');
  
  final warrantyController = TextEditingController();
  final expiryController = TextEditingController();
  final tagsController = TextEditingController();

  // Observables
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Brand> brands = <Brand>[].obs;
  
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedBrandId = ''.obs;
  final RxString selectedUnit = 'pcs'.obs;
  final RxString selectedTaxClass = 'GST 18%'.obs;
  final RxString selectedDiscountType = 'Percentage'.obs;
  final RxString selectedStatus = 'Active'.obs;
  final RxString selectedWarehouse = 'Main Warehouse'.obs;

  final RxBool trackInventory = true.obs;
  final RxBool lowStockAlert = true.obs;
  final RxBool isLoading = false.obs;

  final RxList<File> selectedImages = <File>[].obs;
  
  // Edit mode
  Product? editingProduct;

  // Computed values
  final RxDouble profitMargin = 0.0.obs;
  final RxDouble marginPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadMasterData();
    
    // Check if editing
    if (Get.arguments != null && Get.arguments is Product) {
      editingProduct = Get.arguments as Product;
      _loadEditingData();
    }
    
    // Setup listeners for margin calculation
    costPriceController.addListener(_calculateMargin);
    sellingPriceController.addListener(_calculateMargin);
  }

  void _loadEditingData() {
    final p = editingProduct!;
    nameController.text = p.name;
    skuController.text = p.sku ?? '';
    barcodeController.text = p.barcode ?? '';
    hsnController.text = p.hsnSac ?? '';
    descriptionController.text = p.description ?? '';
    costPriceController.text = p.costPrice?.toStringAsFixed(2) ?? '0.00';
    sellingPriceController.text = p.price.toStringAsFixed(2);
    mrpController.text = p.mrp?.toStringAsFixed(2) ?? '0.00';
    discountValueController.text = p.discountValue.toStringAsFixed(2);
    openingStockController.text = p.stockQuantity.toString();
    reorderLevelController.text = p.reorderLevel.toString();
    reorderQuantityController.text = p.reorderQuantity.toString();
    warrantyController.text = p.warrantyPeriod ?? '';
    expiryController.text = p.expiryPeriod ?? '';
    tagsController.text = p.tags ?? '';
    
    selectedCategoryId.value = p.categoryId ?? '';
    selectedBrandId.value = p.brandId ?? '';
    selectedUnit.value = p.unit;
    selectedTaxClass.value = p.taxClass ?? 'GST 18%';
    selectedDiscountType.value = p.discountType ?? 'Percentage';
    selectedStatus.value = p.status;
    selectedWarehouse.value = p.warehouse ?? 'Main Warehouse';
    
    trackInventory.value = p.trackInventory;
  }

  Future<void> loadMasterData() async {
    categories.assignAll(await db.select(db.categories).get());
    brands.assignAll(await db.select(db.brands).get());
    if (categories.isNotEmpty) selectedCategoryId.value = categories.first.id;
    if (brands.isNotEmpty) selectedBrandId.value = brands.first.id;
  }

  void _calculateMargin() {
    final cost = double.tryParse(costPriceController.text) ?? 0.0;
    final selling = double.tryParse(sellingPriceController.text) ?? 0.0;
    
    profitMargin.value = selling - cost;
    if (selling > 0) {
      marginPercentage.value = (profitMargin.value / selling) * 100;
    } else {
      marginPercentage.value = 0.0;
    }
  }

  void generateSku() {
    final prefix = nameController.text.length >= 3 
      ? nameController.text.substring(0, 3).toUpperCase() 
      : 'PRD';
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    skuController.text = '$prefix-$timestamp';
  }

  void generateBarcode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    barcodeController.text = timestamp;
  }

  Future<void> pickImages() async {
    if (selectedImages.length >= 5) {
      Get.snackbar('Limit Reached', 'You can only upload up to 5 images');
      return;
    }
    
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (var xFile in images) {
        if (selectedImages.length < 5) {
          selectedImages.add(File(xFile.path));
        }
      }
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final id = editingProduct?.id ?? _uuid.v4();
      
      // Check for duplicate SKU if it's a new product or SKU changed
      if (skuController.text.isNotEmpty && (editingProduct == null || editingProduct!.sku != skuController.text)) {
        final existing = await (db.select(db.products)..where((t) => t.sku.equals(skuController.text))).getSingleOrNull();
        if (existing != null) {
          Get.snackbar('Error', 'Product with this SKU already exists');
          isLoading.value = false;
          return;
        }
      }

      final companion = ProductsCompanion(
        id: d.Value(id),
        name: d.Value(nameController.text),
        sku: d.Value(skuController.text),
        barcode: d.Value(barcodeController.text),
        categoryId: d.Value(selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value),
        brandId: d.Value(selectedBrandId.value.isEmpty ? null : selectedBrandId.value),
        price: d.Value(double.tryParse(sellingPriceController.text) ?? 0.0),
        costPrice: d.Value(double.tryParse(costPriceController.text)),
        mrp: d.Value(double.tryParse(mrpController.text)),
        discountType: d.Value(selectedDiscountType.value),
        discountValue: d.Value(double.tryParse(discountValueController.text) ?? 0.0),
        stockQuantity: d.Value(double.tryParse(openingStockController.text) ?? 0.0),
        lowStockAlert: d.Value(double.tryParse(reorderLevelController.text) ?? 5.0),
        trackInventory: d.Value(trackInventory.value),
        reorderLevel: d.Value(double.tryParse(reorderLevelController.text) ?? 0.0),
        reorderQuantity: d.Value(double.tryParse(reorderQuantityController.text) ?? 0.0),
        warehouse: d.Value(selectedWarehouse.value),
        unit: d.Value(selectedUnit.value),
        hsnSac: d.Value(hsnController.text),
        taxClass: d.Value(selectedTaxClass.value),
        gstRate: d.Value(_getGstRateFromClass(selectedTaxClass.value)),
        description: d.Value(descriptionController.text),
        warrantyPeriod: d.Value(warrantyController.text),
        expiryPeriod: d.Value(expiryController.text),
        tags: d.Value(tagsController.text),
        status: d.Value(selectedStatus.value),
      );

      if (editingProduct == null) {
        await db.into(db.products).insert(companion);
      } else {
        await db.update(db.products).replace(companion);
      }

      Get.snackbar('Success', editingProduct == null ? 'Product saved successfully' : 'Product updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      
      // Refresh the master list if it exists in memory
      if (Get.isRegistered<ProductsMasterController>()) {
        Get.find<ProductsMasterController>().refreshAll();
      }
      
      Get.back(); // Return to previous page
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  double _getGstRateFromClass(String taxClass) {
    if (taxClass.contains('18%')) return 18.0;
    if (taxClass.contains('12%')) return 12.0;
    if (taxClass.contains('5%')) return 5.0;
    if (taxClass.contains('28%')) return 28.0;
    return 0.0;
  }

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    hsnController.dispose();
    descriptionController.dispose();
    costPriceController.dispose();
    sellingPriceController.dispose();
    mrpController.dispose();
    discountValueController.dispose();
    openingStockController.dispose();
    reorderLevelController.dispose();
    reorderQuantityController.dispose();
    warrantyController.dispose();
    expiryController.dispose();
    tagsController.dispose();
    super.onClose();
  }
}
