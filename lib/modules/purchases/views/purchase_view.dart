import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/purchase_controller.dart';
import '../../../database/database.dart';

class PurchaseView extends GetView<PurchaseController> {
  const PurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Stock Intake (Purchases)',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Product Selection & Current Items
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildSupplierSelection(),
                  const SizedBox(height: 24),
                  _buildProductPicker(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildItemsList()),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Side: Summary & Save
            _buildSummaryPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. SELECT SUPPLIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<Supplier>(
            value: controller.selectedSupplier.value,
            hint: const Text('Choose a supplier...'),
            items: controller.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (v) => controller.selectedSupplier.value = v,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.local_shipping_outlined)),
          )),
        ],
      ),
    );
  }

  Widget _buildProductPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('2. ADD PRODUCTS TO INTAKE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
          const SizedBox(height: 16),
          Autocomplete<Product>(
            displayStringForOption: (p) => p.name,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<Product>.empty();
              return controller.products.where((p) => p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (p) => controller.addItem(p),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Search product to add...',
                  prefixIcon: Icon(Icons.search),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('ITEM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                Expanded(child: Text('QTY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                Expanded(child: Text('COST PRICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                Expanded(child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.separated(
              itemCount: controller.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(
                        child: TextFormField(
                          initialValue: item.quantity.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                          onChanged: (v) {
                             item.quantity = double.tryParse(v) ?? 0;
                             controller.items.refresh();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: item.costPrice.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8)),
                          onChanged: (v) {
                             item.costPrice = double.tryParse(v) ?? 0;
                             controller.items.refresh();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text('₹${item.total.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: () => controller.removeItem(index)),
                    ],
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('3. PURCHASE SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
          const SizedBox(height: 24),
          _summaryRow('Total Items', controller.items.length.toString()),
          const SizedBox(height: 12),
          Obx(() => _summaryRow('Total Amount', '₹${controller.totalAmount.toStringAsFixed(2)}', isBold: true)),
          const Divider(height: 48),
          const Text('Payment Mode', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('CREDIT (Supplier Ledger)', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.savePurchase(),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
            child: controller.isLoading.value 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('CONFIRM PURCHASE', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
      ],
    );
  }
}
