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
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor,
        ),
        boxShadow: !isDark ? [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ] : [],
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Obx(() {
                  final paginatedProducts = controller.paginatedProducts;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          horizontalMargin: 24,
                          columnSpacing: 32,
                          headingRowHeight: 56,
                          dataRowMinHeight: 64,
                          dataRowMaxHeight: 64,
                          headingRowColor: WidgetStateProperty.all(
                            theme.dividerColor.withOpacity(0.05),
                          ),
                          dividerThickness: 1,
                          columns: [
                            _buildColumn(context, 'Image'),
                            _buildColumn(context, 'Name'),
                            _buildColumn(context, 'Category'),
                            _buildColumn(context, 'Stock', numeric: true),
                            _buildColumn(context, 'MRP', numeric: true),
                            _buildColumn(context, 'Dis', numeric: true),
                            _buildColumn(context, 'Sale Price', numeric: true),
                            _buildColumn(context, 'Status'),
                            _buildColumn(context, 'Action'),
                          ],
                          rows: List.generate(paginatedProducts.length, (index) {
                            final p = paginatedProducts[index];
                            final category = controller.categories.firstWhereOrNull((c) => c.id == p.categoryId)?.name ?? '-';
                            final bool isLowStock = p.stockQuantity <= p.lowStockAlert;
                            final bool isOutOfStock = p.stockQuantity <= 0;
                            
                            return DataRow(
                              cells: [
                                DataCell(_buildImagePreview(context, p.imageUrl)),
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
                                            color: theme.textTheme.bodySmall?.color,
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
                                DataCell(Text(currencyFormat.format(p.price), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: theme.colorScheme.primary))),
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
                });
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  'Showing ${(controller.currentPage.value - 1) * controller.rowsPerPage.value + 1} to '
                  '${((controller.currentPage.value - 1) * controller.rowsPerPage.value + controller.paginatedProducts.length)} '
                  'of ${controller.filteredProducts.length} entries', 
                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)
                )),
                Row(
                  children: [
                    _buildPageBtn(context, '<', false, onTap: () => controller.previousPage()),
                    Obx(() => Text(' Page ${controller.currentPage.value} of ${controller.totalPages} ', 
                      style: TextStyle(fontSize: 12, color: theme.textTheme.bodyLarge?.color))),
                    _buildPageBtn(context, '>', false, onTap: () => controller.nextPage()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBtn(BuildContext context, String text, bool active, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: active ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  DataColumn _buildColumn(BuildContext context, String label, {bool numeric = false}) {
    final theme = Theme.of(context);
    return DataColumn(
      numeric: numeric,
      label: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.8,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String? path) {
    final theme = Theme.of(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: path != null && path.isNotEmpty
            ? (path.startsWith('http') 
                ? Image.network(path, fit: BoxFit.cover) 
                : Image.file(File(path), fit: BoxFit.cover))
            : Icon(Icons.image_not_supported_rounded, size: 20, color: theme.dividerColor),
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
          color: color.withOpacity(0.1),
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900),
      ),
    );
  }
}

