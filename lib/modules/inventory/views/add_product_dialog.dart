import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../controllers/inventory_controller.dart';
import '../../../database/database.dart';

class AddProductDialog extends StatefulWidget {
  final Product? product;
  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<InventoryController>();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _lowStockController;
  late TextEditingController _unitController;
  late TextEditingController _gstRateController;

  String? _selectedCategoryId;
  String? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _priceController = TextEditingController(text: widget.product?.price.toString());
    _costPriceController = TextEditingController(text: widget.product?.costPrice?.toString());
    _stockController = TextEditingController(text: widget.product?.stockQuantity.toString());
    _lowStockController = TextEditingController(text: widget.product?.lowStockAlert.toString());
    _unitController = TextEditingController(text: widget.product?.unit ?? 'pcs');
    _gstRateController = TextEditingController(text: widget.product?.gstRate.toString());
    
    _selectedCategoryId = widget.product?.categoryId;
    _selectedBrandId = widget.product?.brandId;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product == null ? 'Add New Product' : 'Edit Product',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                // Name & Barcode
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(_nameController, 'Product Name', Icons.inventory_2_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(_barcodeController, 'Barcode/SKU', Icons.qr_code_scanner),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category & Brand
                Row(
                  children: [
                    Expanded(child: _buildCategoryDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildBrandDropdown()),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing
                Row(
                  children: [
                    Expanded(child: _buildTextField(_priceController, 'Selling Price', Icons.sell_outlined, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_costPriceController, 'Cost Price', Icons.shopping_bag_outlined, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_gstRateController, 'GST %', Icons.percent, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),

                // Stock
                Row(
                  children: [
                    Expanded(child: _buildTextField(_stockController, 'Opening Stock', Icons.storage_outlined, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_lowStockController, 'Low Stock Alert', Icons.warning_amber_rounded, isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_unitController, 'Unit (pcs, kg...)', Icons.scale_outlined)),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                      child: Text(widget.product == null ? 'ADD PRODUCT' : 'SAVE CHANGES'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
      items: controller.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
      onChanged: (v) => setState(() => _selectedCategoryId = v),
      validator: (v) => v == null ? 'Required' : null,
    ));
  }

  Widget _buildBrandDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
      initialValue: _selectedBrandId,
      decoration: const InputDecoration(labelText: 'Brand', prefixIcon: Icon(Icons.branding_watermark_outlined)),
      items: controller.brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
      onChanged: (v) => setState(() => _selectedBrandId = v),
    ));
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.product == null) {
        controller.addProduct(ProductsCompanion(
          name: d.Value(_nameController.text),
          barcode: d.Value(_barcodeController.text),
          categoryId: d.Value(_selectedCategoryId),
          brandId: d.Value(_selectedBrandId),
          price: d.Value(double.tryParse(_priceController.text) ?? 0.0),
          costPrice: d.Value(double.tryParse(_costPriceController.text)),
          stockQuantity: d.Value(double.tryParse(_stockController.text) ?? 0.0),
          lowStockAlert: d.Value(double.tryParse(_lowStockController.text) ?? 5.0),
          unit: d.Value(_unitController.text),
          gstRate: d.Value(double.tryParse(_gstRateController.text) ?? 0.0),
        ));
      } else {
        controller.updateProduct(widget.product!.copyWith(
          name: _nameController.text,
          barcode: d.Value(_barcodeController.text),
          categoryId: d.Value(_selectedCategoryId),
          brandId: d.Value(_selectedBrandId),
          price: double.tryParse(_priceController.text) ?? 0.0,
          costPrice: d.Value(double.tryParse(_costPriceController.text)),
          stockQuantity: double.tryParse(_stockController.text) ?? 0.0,
          lowStockAlert: double.tryParse(_lowStockController.text) ?? 5.0,
          unit: _unitController.text,
          gstRate: double.tryParse(_gstRateController.text) ?? 0.0,
        ));
      }
      Get.back();
    }
  }
}
