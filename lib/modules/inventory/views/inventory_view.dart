import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/inventory_controller.dart';
import 'add_product_dialog.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Products & Inventory',
      child: Container(
        color: const Color(0xFFF5F7FB),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionHeader(),
              const SizedBox(height: 24),
              _buildStatsSummary(),
              const SizedBox(height: 32),
              _buildFilterBar(),
              const SizedBox(height: 24),
              Expanded(child: _buildProductCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Portfolio', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            Text('Manage your catalog, stock levels, and pricing.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        Row(
          children: [
            _headerButton(Icons.file_download_outlined, 'Import'),
            const SizedBox(width: 12),
            _headerButton(Icons.file_upload_outlined, 'Export'),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => Get.dialog(const AddProductDialog()),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('NEW PRODUCT', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _headerButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: const Color(0xFF475569)),
      label: Text(label, style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Obx(() => Row(
      children: [
        _miniStat('Total Skus', controller.products.length.toString(), Colors.blue),
        const SizedBox(width: 24),
        _miniStat('Out of Stock', controller.products.where((p) => p.stockQuantity <= 0).length.toString(), Colors.red),
        const SizedBox(width: 24),
        _miniStat('Total Value', '₹${controller.products.fold(0.0, (sum, p) => sum + (p.price * p.stockQuantity)).toStringAsFixed(0)}', Colors.green),
      ],
    ));
  }

  Widget _miniStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: const InputDecoration(
                hintText: 'Search by product name, SKU, or barcode...',
                prefixIcon: Icon(Icons.search_rounded),
                filled: true,
                fillColor: Color(0xFFF8FAFC),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _filterChip('All Categories'),
          const SizedBox(width: 10),
          _filterChip('In Stock'),
          const SizedBox(width: 16),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          const SizedBox(width: 16),
          IconButton(onPressed: () {}, icon: const Icon(Icons.grid_view_rounded, color: Colors.blue)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.view_list_rounded, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        final products = controller.filteredProducts;
        if (products.isEmpty) return const Center(child: Text('No products found.'));

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              dataRowMaxHeight: 70,
              horizontalMargin: 24,
              columns: const [
                DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B)))),
                DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B)))),
                DataColumn(label: Text('PRICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B)))),
                DataColumn(label: Text('STOCK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B)))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B)))),
                DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF64748B)))),
              ],
              rows: products.map((p) => _buildDataRow(p)).toList(),
            ),
          ),
        );
      }),
    );
  }

  DataRow _buildDataRow(dynamic p) {
    final bool isLowStock = p.stockQuantity <= p.lowStockAlert;
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image_outlined, color: Colors.grey, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(p.barcode ?? 'No SKU', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        )),
        DataCell(Text('Electronics', style: const TextStyle(color: Color(0xFF475569)))),
        DataCell(Text('₹${p.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
        DataCell(Text('${p.stockQuantity.toInt()} ${p.unit}', style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(_statusChip(isLowStock ? 'Low Stock' : 'Active', isLowStock ? Colors.orange : Colors.green)),
        DataCell(Row(
          children: [
            IconButton(icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.blue), onPressed: () => Get.dialog(AddProductDialog(product: p))),
            IconButton(icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red), onPressed: () {}),
          ],
        )),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
