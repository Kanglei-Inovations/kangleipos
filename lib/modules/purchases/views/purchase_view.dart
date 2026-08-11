import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/purchase_controller.dart';

class PurchaseView extends GetView<PurchaseController> {
  const PurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Purchases',
      child: Obx(() {
        final ctrl = Get.find<PurchaseController>();
        if (ctrl.isLoading.value && ctrl.purchaseHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isDesktop = width >= 1280;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PurchaseKpiGrid(width: width - 360),
                              const SizedBox(height: 18),
                              _MainPurchaseContent(),
                              const SizedBox(height: 18),
                              _BottomActionButtons(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        const SizedBox(
                          width: 340,
                          child: _PurchaseRightRail(),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PurchaseKpiGrid(width: width),
                        const SizedBox(height: 18),
                        _MainPurchaseContent(),
                        const SizedBox(height: 18),
                        _BottomActionButtons(),
                        const SizedBox(height: 18),
                        const _PurchaseRightRail(),
                      ],
                    ),
            );
          },
        );
      }),
    );
  }
}

class _PurchaseKpiGrid extends GetView<PurchaseController> {
  final double width;

  const _PurchaseKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final columns = width >= 1180
        ? 4
        : width >= 640
            ? 2
            : 1;

    final kpis = [
      _PurchaseKpiData(
        title: 'Total Purchases',
        value: controller.totalPurchases,
        growth: 12.8,
        icon: Icons.shopping_cart_outlined,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
      ),
      _PurchaseKpiData(
        title: 'Total Paid',
        value: controller.totalPaid,
        growth: 9.7,
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _PurchaseKpiData(
        title: 'Total Due',
        value: controller.totalDue,
        growth: -8.4,
        icon: Icons.lock_outline,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _PurchaseKpiData(
        title: 'Total Invoices',
        value: controller.totalInvoices.toDouble(),
        growth: 5.2,
        icon: Icons.description_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        sparkline: [10, 12, 11, 14, 13, 16, 15],
        isCurrency: false,
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
        mainAxisExtent: 160,
      ),
      itemBuilder: (context, index) {
        return _PurchaseKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _PurchaseKpiData {
  final String title;
  final double value;
  final double growth;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;
  final bool isCurrency;

  const _PurchaseKpiData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.gradient,
    required this.sparkline,
    this.isCurrency = true,
  });
}

class _PurchaseKpiCard extends StatelessWidget {
  final _PurchaseKpiData data;

  const _PurchaseKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.gradient.first.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.gradient.first, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.isCurrency
                          ? NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value)
                          : data.value.toInt().toString(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        data.growth >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 14,
                        color: data.growth >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.growth.abs()}%',
                        style: TextStyle(
                          color: data.growth >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('vs last month', style: TextStyle(color: muted, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                height: 30,
                child: CustomPaint(
                  painter: _KpiSparklinePainter(points: data.sparkline, color: data.gradient.first),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiSparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _KpiSparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (points.length - 1);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PurchaseTabs extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    final tabs = ['All Purchases', 'Purchase Orders', 'GRN / Receive Notes', 'Returns', 'Bills'];

    return Row(
      children: tabs.map((tab) {
        return Obx(() {
          final isSelected = controller.selectedTab.value == tab;
          return GestureDetector(
            onTap: () => controller.selectedTab.value = tab,
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }
}

class _PurchaseFilterBar extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: muted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (v) => controller.searchQuery.value = v,
                    decoration: InputDecoration(
                      hintText: 'Search by invoice no., supplier...',
                      hintStyle: TextStyle(color: muted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Icon(Icons.qr_code_scanner_rounded, color: muted, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Supplier?>(
              value: controller.selectedSupplierFilter.value,
              hint: Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: muted),
                  const SizedBox(width: 8),
                  Text('All Suppliers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
                ],
              ),
              items: [
                DropdownMenuItem<Supplier?>(
                  value: null,
                  child: Text('All Suppliers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
                ),
                ...controller.suppliers.map((s) {
                  return DropdownMenuItem<Supplier?>(
                    value: s,
                    child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  );
                }),
              ],
              onChanged: (val) => controller.selectedSupplierFilter.value = val,
            ),
          ),
        )),
        const SizedBox(width: 12),
        Obx(() => Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedStatusFilter.value,
              items: ['All Status', 'Paid', 'Partial', 'Due'].map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Row(
                    children: [
                      Icon(Icons.sync_rounded, size: 18, color: muted),
                      const SizedBox(width: 8),
                      Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.selectedStatusFilter.value = val;
              },
            ),
          ),
        )),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'Select Date', icon: Icons.calendar_today_outlined),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            controller.searchQuery.value = '';
            controller.selectedSupplierFilter.value = null;
            controller.selectedStatusFilter.value = 'All Status';
            controller.selectedTab.value = 'All Purchases';
          },
          child: const _ActionButton(icon: Icons.tune_rounded, label: 'Reset Filters'),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterDropdown({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
        ],
      ),
    );
  }
}

class _MainPurchaseContent extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PurchaseTabs(),
          const SizedBox(height: 18),
          _PurchaseFilterBar(),
          const SizedBox(height: 18),
          _PurchaseTable(),
        ],
      ),
    );
  }
}

class _PurchaseTable extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['Invoice No.', 'Supplier', 'Date', 'Total Amount', 'Paid Amount', 'Due Amount', 'Status', 'Actions'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final minTableWidth = 860.0;
        final tableWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9))),
                      ),
                      child: Row(
                        children: columns.map((col) {
                          return Expanded(
                            flex: col == 'Supplier' ? 3 : 2,
                            child: Text(
                              col,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Obx(() {
                      final purchases = controller.paginatedPurchases;
                      if (purchases.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No purchase orders found',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: purchases.length,
                        itemBuilder: (context, index) {
                          return _PurchaseRow(purchase: purchases[index], tableWidth: tableWidth);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            const _TablePagination(),
          ],
        );
      },
    );
  }
}

class _PurchaseRow extends GetView<PurchaseController> {
  final Purchase purchase;
  final double tableWidth;

  const _PurchaseRow({required this.purchase, this.tableWidth = 860});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    final supplier = controller.suppliers.firstWhereOrNull((s) => s.id == purchase.supplierId);
    
    final paidAmount = purchase.grandTotal * 0.8; // Mock
    final dueAmount = purchase.grandTotal - paidAmount;
    final status = dueAmount == 0 ? 'Paid' : dueAmount < purchase.grandTotal ? 'Partial' : 'Due';
    final statusColor = status == 'Paid' ? Colors.green : status == 'Partial' ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // Invoice No
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(purchase.purchaseNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Bill', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Supplier
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(supplier?.name.substring(0, 1).toUpperCase() ?? 'S', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(supplier?.address?.split(',').first ?? 'No Address', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(purchase.purchaseDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(DateFormat('hh:mm a').format(purchase.purchaseDate), style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Total Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(purchase.grandTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          // Paid Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(paidAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green))),
          // Due Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(dueAmount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.red))),
          // Status
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor), textAlign: TextAlign.center),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _TableActionIcon(icon: Icons.visibility_outlined),
                _TableActionIcon(icon: Icons.print_outlined),
                _TableActionIcon(icon: Icons.more_vert_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableActionIcon extends StatelessWidget {
  final IconData icon;
  const _TableActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: Colors.grey),
    );
  }
}

class _TablePagination extends GetView<PurchaseController> {
  const _TablePagination();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalPages = controller.totalPages;
      final currentPage = controller.currentPage.value;

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            InkWell(
              onTap: controller.previousPage,
              borderRadius: BorderRadius.circular(8),
              child: const _PaginationButton(icon: Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 8),
            ...List.generate(totalPages, (index) {
              final page = index + 1;
              return InkWell(
                onTap: () => controller.goToPage(page),
                borderRadius: BorderRadius.circular(8),
                child: _PageNumber(number: page, active: page == currentPage),
              );
            }),
            const SizedBox(width: 8),
            InkWell(
              onTap: controller.nextPage,
              borderRadius: BorderRadius.circular(8),
              child: const _PaginationButton(icon: Icons.chevron_right_rounded),
            ),
            const Spacer(),
            const Text('Rows per page:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.rowsPerPage.value,
                  isDense: true,
                  items: [5, 10, 15, 20].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text('$val', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.setRowsPerPage(val);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  const _PaginationButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18, color: Colors.grey),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool active;
  const _PageNumber({required this.number, this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: active ? const Color(0xFF4F46E5) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text('$number', style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.w800, fontSize: 12))),
    );
  }
}

class _PurchaseRightRail extends StatelessWidget {
  const _PurchaseRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PurchaseSummaryChart(),
        SizedBox(height: 18),
        _TopSuppliersList(),
        SizedBox(height: 18),
        _RecentGrnList(),
      ],
    );
  }
}

class _PurchaseSummaryChart extends GetView<PurchaseController> {
  const _PurchaseSummaryChart();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final data = controller.purchaseSummaryData;

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Purchase Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              _SmallDropdown(label: 'This Month'),
            ],
          ),
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
                    sections: [
                      PieChartSectionData(color: Colors.green, value: data['Paid']!, title: '', radius: 25),
                      PieChartSectionData(color: Colors.orange, value: data['Partial']!, title: '', radius: 25),
                      PieChartSectionData(color: Colors.red, value: data['Due']!, title: '', radius: 25),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(controller.totalPurchases), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Total', style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SummaryLegend(label: 'Paid', amount: data['Paid']!, color: Colors.green, percentage: 79.8),
          const SizedBox(height: 8),
          _SummaryLegend(label: 'Partial', amount: data['Partial']!, color: Colors.orange, percentage: 10.4),
          const SizedBox(height: 8),
          _SummaryLegend(label: 'Due', amount: data['Due']!, color: Colors.red, percentage: 9.8),
        ],
      ),
    );
  }
}

class _SummaryLegend extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final double percentage;

  const _SummaryLegend({required this.label, required this.amount, required this.color, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        Text('${NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount)} ($percentage%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _TopSuppliersList extends GetView<PurchaseController> {
  const _TopSuppliersList();

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
              const Expanded(child: Text('Top Suppliers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _SupplierListItem(name: 'Sharma Traders', amount: 75680, growth: 12.4, color: Colors.red),
          _SupplierListItem(name: 'Vishal Marketing', amount: 65450, growth: 8.6, color: Colors.purple),
          _SupplierListItem(name: 'Gupta Traders', amount: 48750, growth: 5.3, color: Colors.blue),
          _SupplierListItem(name: 'R.K. Enterprises', amount: 39860, growth: 3.7, color: Colors.indigo),
          _SupplierListItem(name: 'Amit & Brothers', amount: 32600, growth: 2.1, color: Colors.green),
        ],
      ),
    );
  }
}

class _SupplierListItem extends StatelessWidget {
  final String name;
  final double amount;
  final double growth;
  final Color color;

  const _SupplierListItem({required this.name, required this.amount, required this.growth, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.1), child: Text(name.substring(0, 1), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              Row(children: [Icon(Icons.arrow_upward_rounded, size: 10, color: Colors.green), Text('$growth%', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))]),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentGrnList extends StatelessWidget {
  const _RecentGrnList();

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
              const Expanded(child: Text('Recent GRN / Receipts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          _GrnItem(no: 'GRN-10045', supplier: 'Sharma Traders', time: '24 May, 11:45 AM', status: 'Received'),
          _GrnItem(no: 'GRN-10044', supplier: 'Gupta Traders', time: '23 May, 04:20 PM', status: 'Received'),
          _GrnItem(no: 'GRN-10043', supplier: 'R.K. Enterprises', time: '22 May, 02:10 PM', status: 'Received'),
          _GrnItem(no: 'GRN-10042', supplier: 'Vishal Marketing', time: '21 May, 10:30 AM', status: 'Received'),
        ],
      ),
    );
  }
}

class _GrnItem extends StatelessWidget {
  final String no, supplier, time, status;
  const _GrnItem({required this.no, required this.supplier, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(no, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                Text(supplier, style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(fontSize: 10, color: muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Received', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActionButtons extends GetView<PurchaseController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BigActionButton(
          label: 'New Purchase',
          icon: Icons.add_rounded,
          bgColor: const Color(0xFF2563EB),
          textColor: Colors.white,
          isPrimary: true,
          onTap: () => _showCreatePurchaseDialog(context, controller),
        ),
        const SizedBox(width: 12),
        _BigActionButton(
          label: 'Purchase Order',
          icon: Icons.assignment_outlined,
          bgColor: const Color(0xFFEFF6FF),
          textColor: const Color(0xFF2563EB),
          borderColor: const Color(0xFFBFDBFE),
          onTap: () => _showCreatePurchaseDialog(context, controller),
        ),
        const SizedBox(width: 12),
        _BigActionButton(
          label: 'GRN / Receive',
          icon: Icons.move_to_inbox_rounded,
          bgColor: const Color(0xFFECFDF5),
          textColor: const Color(0xFF059669),
          borderColor: const Color(0xFFA7F3D0),
          onTap: () => Get.snackbar('GRN / Receive', 'Receive Goods Note modal ready.'),
        ),
        const SizedBox(width: 12),
        _BigActionButton(
          label: 'Purchase Return',
          icon: Icons.assignment_return_outlined,
          bgColor: const Color(0xFFFEF2F2),
          textColor: const Color(0xFFDC2626),
          borderColor: const Color(0xFFFCA5A5),
          onTap: () => Get.snackbar('Purchase Return', 'Purchase Return modal ready.'),
        ),
        const SizedBox(width: 12),
        _BigActionButton(
          label: 'Import',
          icon: Icons.download_rounded,
          bgColor: const Color(0xFFF5F3FF),
          textColor: const Color(0xFF7C3AED),
          borderColor: const Color(0xFFDDD6FE),
          onTap: () => Get.snackbar('Import Purchases', 'Import CSV/Excel functionality ready.'),
        ),
      ],
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor ?? Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: textColor, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallDropdown extends StatelessWidget {
  final String label;
  const _SmallDropdown({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.withOpacity(0.2))),
      child: Row(children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)), const Icon(Icons.keyboard_arrow_down_rounded, size: 14)]),
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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: muted),
          ),
        ],
      ),
    );
  }
}

void _showCreatePurchaseDialog(BuildContext context, PurchaseController controller) {
  if (controller.suppliers.isEmpty) {
    // Add default supplier inline if none exists
    controller.addNewSupplierInline('RK Enterprise', '9876543210');
  }

  controller.items.clear();
  controller.selectedSupplier.value = controller.suppliers.isNotEmpty ? controller.suppliers.first : null;
  controller.supplierInvoiceNumber.value = '';
  controller.paidAmount.value = 0.0;
  controller.isInterStateGst.value = false;

  final invNoController = TextEditingController();
  final prodNameController = TextEditingController();
  final barcodeController = TextEditingController();
  final skuController = TextEditingController();
  final mrpController = TextEditingController(text: '0.00');
  final costPriceController = TextEditingController(text: '0.00');
  final sellingPriceController = TextEditingController(text: '0.00');
  final qtyController = TextEditingController(text: '1');
  final discountController = TextEditingController(text: '0.00');
  final hsnController = TextEditingController();
  final paidController = TextEditingController(text: '0.00');

  String selectedCategory = controller.categories.isNotEmpty ? controller.categories.first.id : '';
  String selectedBrand = controller.brands.isNotEmpty ? controller.brands.first.id : '';
  String selectedUnit = 'pcs';
  String selectedDiscountType = 'FLAT';
  double selectedGst = 18.0;
  Product? selectedExistingProduct;

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 10),
            const Text('New Purchase Entry & Stock Intake', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const Spacer(),
            Obx(() => FilterChip(
              selected: controller.isInterStateGst.value,
              label: Text(controller.isInterStateGst.value ? 'Inter-State (IGST)' : 'Intra-State (CGST + SGST)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
              onSelected: (val) => controller.isInterStateGst.value = val,
              selectedColor: Colors.indigo.withValues(alpha: 0.2),
            )),
          ],
        ),
        content: SizedBox(
          width: 780,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION 1: SUPPLIER & INVOICE HEADER ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() => DropdownButtonFormField<Supplier>(
                                value: controller.selectedSupplier.value,
                                decoration: InputDecoration(
                                  labelText: 'Supplier / Vendor Name *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: controller.suppliers.map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)));
                                }).toList(),
                                onChanged: (val) => controller.selectedSupplier.value = val,
                              )),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryColor),
                              onPressed: () {
                                final sNameCtrl = TextEditingController();
                                final sPhoneCtrl = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (sCtx) => AlertDialog(
                                    title: const Text('Add Vendor / Supplier'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(controller: sNameCtrl, decoration: const InputDecoration(labelText: 'Vendor Name (e.g. RK Enterprise)')),
                                        const SizedBox(height: 12),
                                        TextField(controller: sPhoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(sCtx), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (sNameCtrl.text.isNotEmpty) {
                                            await controller.addNewSupplierInline(sNameCtrl.text.trim(), sPhoneCtrl.text.trim());
                                            if (sCtx.mounted) Navigator.pop(sCtx);
                                          }
                                        },
                                        child: const Text('Save Supplier'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: invNoController,
                          onChanged: (v) => controller.supplierInvoiceNumber.value = v,
                          decoration: InputDecoration(
                            labelText: 'Vendor Invoice / Bill #',
                            hintText: 'e.g. RKE/INV-98241',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- SECTION 2: MERGED PRODUCT ENTRY (AddProductPage fields) ---
                const Text('Product Catalog Entry & Price Breakdown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryColor)),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setStateItemModal) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Obx(() => DropdownButtonFormField<Product?>(
                                  value: selectedExistingProduct,
                                  hint: const Text('Select Existing Product (or type new below)'),
                                  decoration: InputDecoration(
                                    labelText: 'Select Existing Product',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: [
                                    const DropdownMenuItem<Product?>(value: null, child: Text('+ Create / Type New Product Details')),
                                    ...controller.products.map((p) {
                                      return DropdownMenuItem<Product?>(value: p, child: Text('${p.name} (Stock: ${p.stockQuantity})'));
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setStateItemModal(() {
                                      selectedExistingProduct = val;
                                      if (val != null) {
                                        prodNameController.text = val.name;
                                        barcodeController.text = val.barcode ?? '';
                                        skuController.text = val.sku ?? '';
                                        mrpController.text = (val.mrp ?? val.price).toStringAsFixed(2);
                                        costPriceController.text = (val.costPrice ?? 0.0).toStringAsFixed(2);
                                        sellingPriceController.text = val.price.toStringAsFixed(2);
                                        selectedGst = val.gstRate ?? 18.0;
                                        hsnController.text = val.hsnSac ?? '';
                                      }
                                    });
                                  },
                                )),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 6,
                                child: TextField(
                                  controller: prodNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Product Name *',
                                    hintText: 'e.g. LED Bulb 15W',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: barcodeController,
                                  decoration: InputDecoration(
                                    labelText: 'Barcode',
                                    hintText: 'e.g. 8901234567',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: skuController,
                                  decoration: InputDecoration(
                                    labelText: 'SKU / Code',
                                    hintText: 'e.g. BULB-15W',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedUnit,
                                  decoration: InputDecoration(
                                    labelText: 'Unit',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: ['pcs', 'kg', 'g', 'ltr', 'box', 'meter', 'set', 'pack'].map((u) {
                                    return DropdownMenuItem(value: u, child: Text(u));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setStateItemModal(() => selectedUnit = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: mrpController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'MRP (₹)',
                                    prefixText: '₹ ',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: costPriceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Cost Price (₹)',
                                    prefixText: '₹ ',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: sellingPriceController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Selling Price (₹)',
                                    prefixText: '₹ ',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: qtyController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Qty Received',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: discountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Discount',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  value: selectedDiscountType,
                                  decoration: InputDecoration(
                                    labelText: 'Disc Type',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: ['FLAT', 'PERCENT'].map((t) {
                                    return DropdownMenuItem(value: t, child: Text(t == 'FLAT' ? 'Flat (₹)' : '%'));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setStateItemModal(() => selectedDiscountType = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<double>(
                                  value: selectedGst,
                                  decoration: InputDecoration(
                                    labelText: 'GST %',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: [0.0, 5.0, 12.0, 18.0, 28.0].map((r) {
                                    return DropdownMenuItem(value: r, child: Text('${r.toInt()}%'));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setStateItemModal(() => selectedGst = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: hsnController,
                                  decoration: InputDecoration(
                                    labelText: 'HSN Code',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  final name = prodNameController.text.trim();
                                  if (name.isEmpty) {
                                    Get.snackbar('Error', 'Please enter product name');
                                    return;
                                  }

                                  final qty = double.tryParse(qtyController.text) ?? 1.0;
                                  final cPrice = double.tryParse(costPriceController.text) ?? 0.0;
                                  final mrpVal = double.tryParse(mrpController.text) ?? cPrice;
                                  final sPrice = double.tryParse(sellingPriceController.text) ?? mrpVal;
                                  final discVal = double.tryParse(discountController.text) ?? 0.0;

                                  final item = PurchaseItem(
                                    product: selectedExistingProduct,
                                    productName: name,
                                    barcode: barcodeController.text.trim(),
                                    sku: skuController.text.trim(),
                                    categoryId: selectedCategory,
                                    brandId: selectedBrand,
                                    unit: selectedUnit,
                                    quantity: qty,
                                    mrp: mrpVal,
                                    costPrice: cPrice,
                                    sellingPrice: sPrice,
                                    discountType: selectedDiscountType,
                                    discountValue: discVal,
                                    gstRate: selectedGst,
                                    hsnCode: hsnController.text.trim(),
                                  );

                                  controller.addItem(item);

                                  // Reset item inputs
                                  prodNameController.clear();
                                  barcodeController.clear();
                                  skuController.clear();
                                  mrpController.text = '0.00';
                                  costPriceController.text = '0.00';
                                  sellingPriceController.text = '0.00';
                                  qtyController.text = '1';
                                  discountController.text = '0.00';
                                  hsnController.clear();
                                  setStateItemModal(() => selectedExistingProduct = null);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('+ Add Item', style: TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // --- SECTION 3: INVOICE TABLE & LIVE TAX SUMMARY CARD ---
                Obx(() {
                  if (controller.items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('No items added to invoice yet.', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600))),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              color: AppTheme.primaryColor.withValues(alpha: 0.06),
                              child: const Row(
                                children: [
                                  Expanded(flex: 4, child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  Expanded(flex: 2, child: Text('MRP / Cost', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  Expanded(flex: 2, child: Text('Qty x Price', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  Expanded(flex: 2, child: Text('Discount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  Expanded(flex: 2, child: Text('Taxable', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  Expanded(flex: 2, child: Text('GST Tax', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  Expanded(flex: 2, child: Text('Total (₹)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                  SizedBox(width: 30),
                                ],
                              ),
                            ),
                            ...controller.items.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
                                child: Row(
                                  children: [
                                    Expanded(flex: 4, child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
                                    Expanded(flex: 2, child: Text('MRP ₹${item.mrp.toStringAsFixed(0)} / ₹${item.costPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                                    Expanded(flex: 2, child: Text('${item.quantity} x ₹${item.costPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                                    Expanded(flex: 2, child: Text('₹${item.discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.orange))),
                                    Expanded(flex: 2, child: Text('₹${item.taxableAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11))),
                                    Expanded(flex: 2, child: Text('${item.gstRate.toInt()}% (₹${item.taxAmount.toStringAsFixed(2)})', style: const TextStyle(fontSize: 11, color: Colors.indigo))),
                                    Expanded(flex: 2, child: Text('₹${item.totalItemAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                      onPressed: () => controller.removeItem(idx),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // FINANCIAL & GST SUMMARY BREAKDOWN CARD
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal Gross Amount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                Text('₹ ${NumberFormat('#,##,##0.00').format(controller.subtotalGrossAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Discount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
                                Text('- ₹ ${NumberFormat('#,##,##0.00').format(controller.totalDiscountAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Taxable Value:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                Text('₹ ${NumberFormat('#,##,##0.00').format(controller.totalTaxableAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (!controller.isInterStateGst.value) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('CGST Amount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.indigo)),
                                  Text('₹ ${NumberFormat('#,##,##0.00').format(controller.totalCgstAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.indigo)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('SGST Amount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.indigo)),
                                  Text('₹ ${NumberFormat('#,##,##0.00').format(controller.totalSgstAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.indigo)),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('IGST Amount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.indigo)),
                                  Text('₹ ${NumberFormat('#,##,##0.00').format(controller.totalTaxAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.indigo)),
                                ],
                              ),
                            ],
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grand Total Invoice Amount:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                                Text('₹ ${NumberFormat('#,##,##0.00').format(controller.grandTotalAmount)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // SECTION 4: PAYMENT PAYOUT & VENDOR LEDGER
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: TextField(
                              controller: paidController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (v) {
                                controller.paidAmount.value = double.tryParse(v) ?? 0.0;
                              },
                              decoration: InputDecoration(
                                labelText: 'Amount Paid to Vendor (₹)',
                                prefixText: '₹ ',
                                hintText: 'Enter cash/UPI payout amount',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: Obx(() => DropdownButtonFormField<String>(
                              value: controller.paymentMethod.value,
                              decoration: InputDecoration(
                                labelText: 'Payment Mode',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: ['CASH', 'UPI', 'BANK_TRANSFER', 'CREDIT'].map((m) {
                                return DropdownMenuItem(value: m, child: Text(m));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controller.paymentMethod.value = val;
                              },
                            )),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              if (controller.items.isEmpty) {
                Get.snackbar('Empty Invoice', 'Please add at least one product item.');
                return;
              }
              await controller.savePurchase();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Save Purchase & Update Catalog + Stock', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    },
  );
}
