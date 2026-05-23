import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/inventory_controller.dart';
import 'add_product_dialog.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Inventory',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InventoryKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ProductInventoryPanel()),
                        const SizedBox(width: 18),
                        const SizedBox(width: 330, child: _RightSidePanels()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _ProductInventoryPanel(),
                        const SizedBox(height: 18),
                        const _RightSidePanels(),
                      ],
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _InventoryKpiGrid extends GetView<InventoryController> {
  final double width;

  const _InventoryKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1180
        ? 5
        : width >= 860
            ? 3
            : width >= 560
                ? 2
                : 1;

    final kpis = [
      _InventoryKpiData(
        title: 'Total Products',
        value: controller.totalProducts.toDouble(),
        subtitle: 'All Products',
        icon: Icons.inventory_2_rounded,
        gradient: [const Color(0xFF38BDF8), const Color(0xFF2563EB)],
      ),
      _InventoryKpiData(
        title: 'Total Stock',
        value: controller.totalStock,
        subtitle: 'Total stock available',
        icon: Icons.assignment_turned_in_rounded,
        gradient: [const Color(0xFF34D399), const Color(0xFF10B981)],
      ),
      _InventoryKpiData(
        title: 'Low Stock',
        value: controller.lowStockCount.toDouble(),
        subtitle: 'Products running low',
        icon: Icons.warning_amber_rounded,
        gradient: [const Color(0xFFFBBF24), const Color(0xFFF97316)],
      ),
      _InventoryKpiData(
        title: 'Out of Stock',
        value: controller.outOfStockCount.toDouble(),
        subtitle: 'Products out of stock',
        icon: Icons.remove_shopping_cart_rounded,
        gradient: [const Color(0xFFF9A8D4), const Color(0xFFF43F5E)],
      ),
      _InventoryKpiData(
        title: 'Stock Value',
        value: controller.totalStockValue,
        subtitle: 'Total inventory value',
        icon: Icons.account_balance_wallet_rounded,
        gradient: [const Color(0xFFC084FC), const Color(0xFF8B5CF6)],
        currency: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 110,
      ),
      itemBuilder: (context, index) {
        return _KpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _InventoryKpiData {
  final String title;
  final double value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final bool currency;

  const _InventoryKpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.currency = false,
  });
}

class _KpiCard extends StatelessWidget {
  final _InventoryKpiData data;

  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: data.gradient.map((c) => c.withOpacity(0.15)).toList()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.gradient.first, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.currency
                      ? NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(data.value)
                      : NumberFormat.decimalPattern('en_IN').format(data.value.round()),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInventoryPanel extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Product Inventory',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              _InventorySearchField(),
              const SizedBox(width: 12),
              _ActionButton(icon: Icons.tune_rounded, label: 'Filter'),
              const SizedBox(width: 12),
              _ActionButton(icon: Icons.category_outlined, label: 'Category'),
              const SizedBox(width: 12),
              _ExportButton(),
            ],
          ),
          const SizedBox(height: 20),
          _InventoryTable(),
          const SizedBox(height: 20),
          _InventoryPagination(),
        ],
      ),
    );
  }
}

class _InventorySearchField extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      width: 280,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: muted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search product...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: muted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: muted),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.ios_share_rounded, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Export',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}

class _InventoryTable extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = [
      'Product',
      'SKU / Code',
      'Category',
      'Stock',
      'Reserved',
      'Available',
      'Unit Cost',
      'Stock Value',
      'Status',
      'Action'
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: i == 0 ? 3 : 2,
                  child: Text(
                    columns[i],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted),
                  ),
                ),
            ],
          ),
        ),
        Obx(() {
          final products = controller.filteredProducts;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductRow(product: product);
            },
          );
        }),
      ],
    );
  }
}

class _ProductRow extends GetView<InventoryController> {
  final Product product;

  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = controller.categories.firstWhereOrNull((c) => c.id == product.categoryId)?.name ?? 'Others';
    
    final status = product.stockQuantity <= 0 
        ? 'Out of Stock' 
        : product.stockQuantity <= product.lowStockAlert 
            ? 'Low Stock' 
            : 'In Stock';
            
    final statusColor = product.stockQuantity <= 0 
        ? Colors.red 
        : product.stockQuantity <= product.lowStockAlert 
            ? Colors.orange 
            : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
          // Product Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: product.imageUrl != null 
                      ? Image.network(product.imageUrl!, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 20))
                      : const Icon(Icons.image_outlined, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // SKU
          Expanded(flex: 2, child: Text(product.sku ?? '-', style: const TextStyle(fontSize: 12))),
          // Category
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.purple),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Stock
          Expanded(flex: 2, child: Text('${product.stockQuantity.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700))),
          // Reserved
          Expanded(flex: 2, child: const Text('0', style: TextStyle(fontSize: 12))),
          // Available
          Expanded(
            flex: 2,
            child: Text(
              '${product.stockQuantity.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
            ),
          ),
          // Unit Cost
          Expanded(
            flex: 2,
            child: Text(
              NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(product.costPrice ?? 0),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // Stock Value
          Expanded(
            flex: 2,
            child: Text(
              NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(product.stockQuantity * (product.costPrice ?? 0)),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryPagination extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Row(
      children: [
        Text(
          'Showing 1 to ${controller.filteredProducts.length} of ${controller.totalProducts} entries',
          style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _PageButton(label: '<', active: false),
        const SizedBox(width: 8),
        _PageButton(label: '1', active: true),
        const SizedBox(width: 8),
        _PageButton(label: '2', active: false),
        const SizedBox(width: 8),
        _PageButton(label: '3', active: false),
        const SizedBox(width: 8),
        _PageButton(label: '>', active: false),
        const SizedBox(width: 16),
        _ItemsPerPageSelector(),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final bool active;

  const _PageButton({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ItemsPerPageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: const [
          Text('10 / page', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ],
      ),
    );
  }
}

class _RightSidePanels extends StatelessWidget {
  const _RightSidePanels();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _StockAlertsPanel(),
        SizedBox(height: 18),
        _CategorySummaryPanel(),
        SizedBox(height: 18),
        _StockValueSummaryPanel(),
      ],
    );
  }
}

class _StockAlertsPanel extends GetView<InventoryController> {
  const _StockAlertsPanel();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Stock Alerts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AlertItem(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            title: 'Low Stock',
            subtitle: '${controller.lowStockCount} products are running low',
            count: controller.lowStockCount,
          ),
          const SizedBox(height: 10),
          _AlertItem(
            icon: Icons.remove_shopping_cart_rounded,
            color: Colors.red,
            title: 'Out of Stock',
            subtitle: '${controller.outOfStockCount} products are out of stock',
            count: controller.outOfStockCount,
          ),
          const SizedBox(height: 10),
          const _AlertItem(
            icon: Icons.event_busy_rounded,
            color: Colors.amber,
            title: 'Expiring Soon',
            subtitle: '5 products are expiring soon',
            count: 5,
          ),
          const SizedBox(height: 10),
          const _AlertItem(
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            title: 'Overstock',
            subtitle: '3 products are overstocked',
            count: 3,
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int count;

  const _AlertItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                Text(subtitle, style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(
            '$count',
            style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 16, color: muted),
        ],
      ),
    );
  }
}

class _CategorySummaryPanel extends GetView<InventoryController> {
  const _CategorySummaryPanel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final categoryCounts = controller.categoryCounts;
    final total = controller.totalProducts;
    
    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.indigo,
      Colors.teal,
    ];

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Category Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: categoryCounts.entries.indexed.map((e) {
                      final index = e.$1;
                      final entry = e.$2;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: entry.value.toDouble(),
                        title: '',
                        radius: 30,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...categoryCounts.entries.indexed.map((e) {
            final index = e.$1;
            final entry = e.$2;
            final percentage = (entry.value / total * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: colors[index % colors.length], borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  Text('$percentage%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StockValueSummaryPanel extends GetView<InventoryController> {
  const _StockValueSummaryPanel();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Stock Value Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: const [
                    Text('This Month', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Total Stock Value', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(controller.totalStockValue),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 14),
              const Text(' 8.5%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 12)),
              Text(' vs last month', style: TextStyle(color: muted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Purchase Value', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(controller.totalStockValue),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sale Value', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('₹ 0.00', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _AddProductButton(),
        ],
      ),
    );
  }
}

class _AddProductButton extends StatelessWidget {
  const _AddProductButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Get.dialog(const AddProductDialog()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_rounded),
            SizedBox(width: 8),
            Text('Add Product', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
