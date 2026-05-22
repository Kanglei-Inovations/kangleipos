import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/layout/main_layout.dart';
import '../../../widgets/common/glass_panel.dart';
import '../controllers/products_master_controller.dart';
import '../widgets/master_filter_bar.dart';
import '../widgets/products_table.dart';
import '../widgets/categories_table.dart';
import '../widgets/brands_table.dart';
import '../widgets/units_table.dart';
import '../widgets/master_info_banner.dart';
import '../widgets/master_dialogs.dart';

class ProductsMasterPage extends GetView<ProductsMasterController> {
  const ProductsMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Products & Master Data',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Column(
            children: [
              _buildHeaderActions(context),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const SizedBox(
                          height: 400, child: Center(child: CircularProgressIndicator()));
                    }

                    // Only Products tab gets the new full layout
                    if (controller.selectedTabIndex.value == 0) {
                      return _buildProductsTabUI(context, width, isDesktop);
                    }

                    // Other tabs keep a simpler layout
                    return _buildOtherTabsUI(context, width);
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductsTabUI(BuildContext context, double width, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiGrid(context, width),
        const SizedBox(height: 5),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildMainTableSection(context),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 340,
                child: _buildRightSidebar(context),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildMainTableSection(context),
              const SizedBox(height: 10),
              _buildRightSidebar(context),
            ],
          ),
        const SizedBox(height: 32),
        const MasterInfoBanner(),
      ],
    );
  }

  Widget _buildOtherTabsUI(BuildContext context, double width) {
    return Column(
      children: [
        MasterFilterBar(onSearch: controller.updateSearch),
        const SizedBox(height: 10),
        _PanelCard(
          title: _getTabTitle(),
          child: _buildTabContent(),
        ),
      ],
    );
  }

  String _getTabTitle() {
    switch (controller.selectedTabIndex.value) {
      case 1:
        return 'Categories';
      case 2:
        return 'Brands';
      case 3:
        return 'Units';
      default:
        return '';
    }
  }

  Widget _buildTabContent() {
    switch (controller.selectedTabIndex.value) {
      case 1:
        return CategoriesTable(categories: controller.filteredCategories);
      case 2:
        return BrandsTable(brands: controller.filteredBrands);
      case 3:
        return UnitsTable(units: controller.dummyUnits);
      default:
        return const SizedBox();
    }
  }

  Widget _buildKpiGrid(BuildContext context, double width) {
    final columns = width >= 1400 ? 5 : (width >= 900 ? 3 : (width >= 600 ? 2 : 1));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      mainAxisExtent: 140,
      children: [
        _KpiCard(
          title: 'Total Products',
          value: controller.totalProductsCount.value.toDouble(),
          icon: Icons.inventory_2_rounded,
          gradient: const [Color(0xFF38BDF8), Color(0xFF2563EB)],
          growth: 12.5,
          index: 0,
        ),
        _KpiCard(
          title: 'In Stock',
          value: (controller.totalProductsCount.value * 0.85).roundToDouble(),
          icon: Icons.check_circle_rounded,
          gradient: const [Color(0xFF34D399), Color(0xFF10B981)],
          growth: 8.2,
          index: 1,
        ),
        _KpiCard(
          title: 'Low Stock',
          value: 128,
          icon: Icons.warning_amber_rounded,
          gradient: const [Color(0xFFFBBF24), Color(0xFFF97316)],
          growth: -2.4,
          index: 2,
        ),
        _KpiCard(
          title: 'Out of Stock',
          value: 18,
          icon: Icons.remove_shopping_cart_rounded,
          gradient: const [Color(0xFFF9A8D4), Color(0xFFF43F5E)],
          growth: -5.1,
          index: 3,
        ),
        _KpiCard(
          title: 'Total Value',
          value: 1245600,
          currency: true,
          icon: Icons.account_balance_wallet_rounded,
          gradient: const [Color(0xFFC084FC), Color(0xFF8B5CF6)],
          growth: 15.4,
          index: 4,
        ),
      ],
    );
  }

  Widget _buildMainTableSection(BuildContext context) {
    return Column(
      children: [
        MasterFilterBar(onSearch: controller.updateSearch),
        const SizedBox(height: 5),
        ProductsTable(products: controller.filteredProducts)
        // _PanelCard(
        //   title: 'Product Catalog',
        //   actionLabel: 'View Detailed Report',
        //   child: ProductsTable(products: controller.filteredProducts),
        // ),
      ],
    );
  }

  Widget _buildRightSidebar(BuildContext context) {
    return Column(
      children: [
        const _CategoryDonutCard(),
        const SizedBox(height: 20),
        const _TopSellingProductsCard(),
        const SizedBox(height: 20),
        const _StockAlertsCard(),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTabs(),
        Row(
          children: [
            _actionButton(context, Icons.download_rounded, 'Import', () => _showImportDialog()),
            const SizedBox(width: 8),
            _actionButton(context, Icons.upload_rounded, 'Export', () => _handleExport()),
            const SizedBox(width: 12),
            _addNewButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final List<String> tabs = ['Products', 'Categories', 'Brands', 'Units'];
    return Obx(() => Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = controller.selectedTabIndex.value == index;
        return Padding(
          padding: const EdgeInsets.only(right: 32),
          child: InkWell(
            onTap: () => controller.selectedTabIndex.value = index,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  width: isSelected ? 24 : 0,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                      )
                    ] : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addNewButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Get.dialog(const MasterAddNewModal(), barrierDismissible: true),
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
      label: const Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  void _showImportDialog() {
    Get.defaultDialog(
      title: 'Import Data',
      content: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Upload your CSV or Excel file to bulk import products.'),
      ),
      textConfirm: 'SELECT FILE',
      onConfirm: () => Get.back(),
    );
  }

  void _handleExport() {
    Get.snackbar('Exporting', 'Generating PDF and Excel reports...', backgroundColor: Colors.blue, colorText: Colors.white);
  }
}

// Re-implementing some dashboard-style private widgets here for clean encapsulation
class _KpiCard extends StatelessWidget {
  final String title;
  final double value;
  final bool currency;
  final IconData icon;
  final List<Color> gradient;
  final double growth;
  final int index;

  const _KpiCard({
    required this.title,
    required this.value,
    this.currency = false,
    required this.icon,
    required this.gradient,
    required this.growth,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.8),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              final formatted = currency
                  ? NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '\u20B9 ',
                      decimalDigits: 0,
                    ).format(val)
                  : NumberFormat.decimalPattern('en_IN').format(val.round());

              return Text(
                formatted,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                growth >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: growth >= 0 ? AppTheme.successColor : AppTheme.dangerColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${growth.abs()}%',
                style: TextStyle(
                  color: growth >= 0 ? AppTheme.successColor : AppTheme.dangerColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'this week',
                style: TextStyle(
                  color: muted.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (60 * index).ms).slideY(begin: 0.1, end: 0);
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final Widget? trailing;

  const _PanelCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(18),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.82),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              if (actionLabel != null)
                TextButton(
                  onPressed: () {},
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CategoryDonutCard extends StatelessWidget {
  const _CategoryDonutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(18),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.8),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Sales by Category',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              _ChartFilter(label: 'This Month', light: !isDark),
              const SizedBox(width: 10),
              _TinyIconButton(icon: Icons.more_horiz_rounded, dark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(color: const Color(0xFF3B82F6), value: 40, radius: 25, title: ''),
                      PieChartSectionData(color: const Color(0xFF8B5CF6), value: 30, radius: 25, title: ''),
                      PieChartSectionData(color: const Color(0xFF10B981), value: 15, radius: 25, title: ''),
                      PieChartSectionData(color: const Color(0xFFF59E0B), value: 15, radius: 25, title: ''),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppTheme.lightMutedTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '2.4K',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.lightTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSellingProductsCard extends StatelessWidget {
  const _TopSellingProductsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final products = [
      ('iPhone 15 Pro', '45 sold', const Color(0xFF3B82F6)),
      ('MacBook Air M3', '32 sold', const Color(0xFF8B5CF6)),
      ('AirPods Pro 2', '28 sold', const Color(0xFF10B981)),
      ('Sony WH-1000XM5', '24 sold', const Color(0xFFF59E0B)),
      ('iPad Pro 12.9', '18 sold', const Color(0xFFF43F5E)),
    ];

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(18),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.8),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Selling Products',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 16),
          for (final p in products)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: p.$3.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_bag_rounded, color: p.$3, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.$1,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          p.$2,
                          style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.trending_up_rounded, color: AppTheme.successColor, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StockAlertsCard extends StatelessWidget {
  const _StockAlertsCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(18),
      color: isDark
          ? const Color(0xFF1E293B).withValues(alpha: 0.62)
          : Colors.white.withValues(alpha: 0.8),
      border: Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stock Alerts',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _AlertTile(
            icon: Icons.warning_amber_rounded,
            title: 'Low Stock',
            subtitle: '128 Products',
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _AlertTile(
            icon: Icons.remove_shopping_cart_rounded,
            title: 'Out of Stock',
            subtitle: '18 Products',
            color: const Color(0xFFF43F5E),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _AlertTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ChartFilter extends StatelessWidget {
  final String label;
  final bool light;

  const _ChartFilter({required this.label, this.light = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = light ? (isDark ? Colors.white : Colors.black) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 14),
        ],
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  final IconData icon;
  final bool dark;

  const _TinyIconButton({required this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, size: 16, color: dark ? Colors.white70 : Colors.black54),
    );
  }
}
