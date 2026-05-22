import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../database/database.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/products_master_controller.dart';

class ProductsTable extends StatelessWidget {
  final List<Product> products;

  const ProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsMasterController>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Products List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('SKU / Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: List.generate(products.length, (index) {
                final p = products[index];
                final bool isLowStock = p.stockQuantity <= p.lowStockAlert;
                
                return DataRow(
                  onSelectChanged: (v) {},
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(p.barcode ?? '-')),
                    DataCell(Text(p.unit)),
                    DataCell(_statusChip(isLowStock ? 'Low Stock' : 'Active', isLowStock ? Colors.orange : Colors.green)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), 
                          onPressed: () => Get.toNamed(AppRoutes.ADD_PRODUCT, arguments: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), 
                          onPressed: () => _confirmDelete(p, controller),
                        ),
                      ],
                    )),
                  ]
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product p, ProductsMasterController controller) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete ${p.name}?',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await (controller.db.delete(controller.db.products)..where((t) => t.id.equals(p.id))).go();
        controller.refreshAll();
        Get.back();
      },
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
