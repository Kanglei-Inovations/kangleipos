import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../database/database.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/products_master_controller.dart';

class ProductsTable extends StatelessWidget {
  final List<Product> products;

  const ProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsMasterController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: DataTable(
                  horizontalMargin: 24,
                  columnSpacing: 32,
                  headingRowHeight: 56,
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
                  ),
                  dividerThickness: 1,
                  columns: [
                    _buildColumn('Image'),
                    _buildColumn('Name'),
                    _buildColumn('Category'),
                    _buildColumn('Stock', numeric: true),
                    _buildColumn('MRP', numeric: true),
                    _buildColumn('Dis', numeric: true),
                    _buildColumn('Sale Price', numeric: true),
                    _buildColumn('Status'),
                    _buildColumn('Action'),
                  ],
                  rows: List.generate(products.length, (index) {
                    final p = products[index];
                    final category = controller.categories.firstWhereOrNull((c) => c.id == p.categoryId)?.name ?? '-';
                    final bool isLowStock = p.stockQuantity <= p.lowStockAlert;
                    final bool isOutOfStock = p.stockQuantity <= 0;
                    
                    return DataRow(
                      cells: [
                        DataCell(_buildImagePreview(p.imageUrl)),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                              if (p.sku != null && p.sku!.isNotEmpty)
                                Text(
                                  p.sku!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        DataCell(Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(
                          Text(
                            '${p.stockQuantity.toInt()} ${p.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isOutOfStock ? AppTheme.dangerColor : (isLowStock ? Colors.orange : null),
                            ),
                          ),
                        ),
                        DataCell(Text(currencyFormat.format(p.mrp ?? 0), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                        DataCell(
                          Text(
                            p.discountType == 'Percentage' ? '${p.discountValue}%' : currencyFormat.format(p.discountValue),
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                        DataCell(Text(currencyFormat.format(p.price), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryColor))),
                        DataCell(_statusChip(
                            isOutOfStock ? 'Out of Stock' : (isLowStock ? 'Low Stock' : 'Active'),
                            isOutOfStock ? AppTheme.dangerColor : (isLowStock ? Colors.orange : AppTheme.successColor))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionIconButton(Icons.edit_note_rounded, Colors.blue, 
                                () => Get.toNamed(AppRoutes.ADD_PRODUCT, arguments: p)),
                            const SizedBox(width: 8),
                            _actionIconButton(Icons.delete_sweep_rounded, Colors.redAccent, 
                                () => _confirmDelete(p, controller)),
                          ],
                        )),
                      ],
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataColumn _buildColumn(String label, {bool numeric = false}) {
    return DataColumn(
      numeric: numeric,
      label: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.8,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? path) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: path != null && path.isNotEmpty
            ? (path.startsWith('http') 
                ? Image.network(path, fit: BoxFit.cover) 
                : Image.file(File(path), fit: BoxFit.cover))
            : const Icon(Icons.image_not_supported_rounded, size: 20, color: Color(0xFFCBD5E1)),
      ),
    );
  }

  Widget _actionIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _confirmDelete(Product p, ProductsMasterController controller) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      titleStyle: const TextStyle(fontWeight: FontWeight.w900),
      middleText: 'Are you sure you want to remove this product from catalog?',
      textConfirm: 'DELETE',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey,
      onConfirm: () async {
        await (controller.db.delete(controller.db.products)..where((t) => t.id.equals(p.id))).go();
        controller.refreshAll();
        Get.back();
      },
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900),
      ),
    );
  }
}
