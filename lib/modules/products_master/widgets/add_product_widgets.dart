import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../controllers/add_product_controller.dart';

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class ProductBasicInfoCard extends GetView<AddProductController> {
  const ProductBasicInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Basic Information',
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            _buildTextField(controller.nameController, 'Product Name', 'Enter full product name', isRequired: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller.skuController, 
                    'SKU / Product Code', 
                    'e.g. SKU123', 
                    isRequired: true,
                    suffix: IconButton(
                      icon: const Icon(Icons.auto_fix_high_rounded, color: Colors.purple, size: 20),
                      onPressed: () => controller.generateSku(),
                      tooltip: 'Auto-generate SKU',
                    ),
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller.barcodeController, 
                    'Barcode', 
                    'Scan or enter barcode',
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.auto_fix_high_rounded, color: Colors.purple, size: 20),
                          onPressed: () => controller.generateBarcode(),
                          tooltip: 'Auto-generate Barcode',
                        ),
                        IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 20), onPressed: () {}),
                      ],
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildDropdown('Category', controller.categories.map((c) => c.name).toList(), (v) => controller.selectedCategoryId.value = controller.categories.firstWhere((c) => c.name == v).id)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('Brand', controller.brands.map((b) => b.name).toList(), (v) => controller.selectedBrandId.value = controller.brands.firstWhere((b) => b.name == v).id)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildDropdown('Unit', ['pcs', 'kg', 'box', 'ltr', 'm'], (v) => controller.selectedUnit.value = v!)),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown('Tax Class', ['GST 0%', 'GST 5%', 'GST 12%', 'GST 18%', 'GST 28%'], (v) => controller.selectedTaxClass.value = v!)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(controller.hsnController, 'HSN / SAC Code', 'e.g. 8471'),
            const SizedBox(height: 20),
            _buildTextField(controller.descriptionController, 'Description', 'Product details...', maxLines: 3),
          ],
        ),
      ),
    );
  }
}

class ProductImageUploadCard extends GetView<AddProductController> {
  const ProductImageUploadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Product Images',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropTarget(
            onDragDone: (detail) {
              // TODO: Implement desktop drag-drop file handling
            },
            child: InkWell(
              onTap: () => controller.pickImages(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text('Drag & drop images or click to upload', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    Text('Supported: JPG, PNG, WebP (Max 5 images)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(controller.selectedImages.length, (index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(controller.selectedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => controller.removeImage(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              );
            }),
          )),
        ],
      ),
    );
  }
}

class ProductPricingCard extends GetView<AddProductController> {
  const ProductPricingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Pricing Information',
      child: Column(
        children: [
          _buildTextField(controller.costPriceController, 'Cost Price', '0.00', prefixText: '₹', isNumber: true),
          const SizedBox(height: 20),
          _buildTextField(controller.sellingPriceController, 'Selling Price', '0.00', prefixText: '₹', isNumber: true),
          const SizedBox(height: 20),
          _buildTextField(controller.mrpController, 'MRP', '0.00', prefixText: '₹', isNumber: true),
          const SizedBox(height: 24),
          _buildMarginIndicator(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDropdown('Discount Type', ['Percentage', 'Flat'], (v) => controller.selectedDiscountType.value = v!)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(controller.discountValueController, 'Value', '0.00', isNumber: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarginIndicator() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profit Margin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              Text('₹${controller.profitMargin.value.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${controller.marginPercentage.value.toStringAsFixed(2)}%',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    ));
  }
}

class ProductInventoryCard extends GetView<AddProductController> {
  const ProductInventoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Inventory Information',
      child: Column(
        children: [
          Obx(() => SwitchListTile(
            title: const Text('Track Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            value: controller.trackInventory.value,
            onChanged: (v) => controller.trackInventory.value = v,
            contentPadding: EdgeInsets.zero,
          )),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(child: _buildTextField(controller.openingStockController, 'Opening Stock', '0', isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildDropdown('Warehouse', ['Main Warehouse', 'Store A', 'Warehouse B'], (v) => controller.selectedWarehouse.value = v!)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField(controller.reorderLevelController, 'Reorder Level', '5', isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(controller.reorderQuantityController, 'Reorder Qty', '10', isNumber: true)),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => CheckboxListTile(
            title: const Text('Notify when stock is low', style: TextStyle(fontSize: 13)),
            value: controller.lowStockAlert.value,
            onChanged: (v) => controller.lowStockAlert.value = v!,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          )),
        ],
      ),
    );
  }
}

class ProductAdditionalInfoCard extends GetView<AddProductController> {
  const ProductAdditionalInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Additional Information',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField(controller.warrantyController, 'Warranty Period', 'e.g. 1 Year')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(controller.expiryController, 'Expiry Period', 'e.g. 6 Months')),
            ],
          ),
          const SizedBox(height: 20),
          _buildDropdown('Product Status', ['Active', 'Inactive', 'Draft'], (v) => controller.selectedStatus.value = v!),
          const SizedBox(height: 20),
          _buildTextField(controller.tagsController, 'Tags', 'comma separated tags...'),
        ],
      ),
    );
  }
}

// Common Widget Helpers
Widget _buildTextField(TextEditingController ctrl, String label, String hint, {bool isRequired = false, bool isNumber = false, int maxLines = 1, Widget? suffix, String? prefixText}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
          children: [
            if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Colors.white,
          prefixText: prefixText,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.blue, width: 2)),
        ),
        validator: isRequired ? (v) => v!.isEmpty ? 'This field is required' : null : null,
      ),
    ],
  );
}

Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    ],
  );
}
