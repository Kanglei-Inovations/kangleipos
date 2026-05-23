import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/expense_controller.dart';
import 'add_expense_dialog.dart';

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Expenses',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.expenses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ExpenseKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _MainExpenseContent()),
                        const SizedBox(width: 18),
                        const Expanded(flex: 3, child: _ExpenseRightRail()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _MainExpenseContent(),
                        const SizedBox(height: 18),
                        const _ExpenseRightRail(),
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

class _ExpenseKpiGrid extends GetView<ExpenseController> {
  final double width;

  const _ExpenseKpiGrid({required this.width});

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
      _ExpenseKpiData(
        title: 'Total Expenses',
        value: controller.totalExpenses,
        growth: 8.5,
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        sparkline: [25, 30, 28, 35, 32, 40, 38],
      ),
      _ExpenseKpiData(
        title: 'Total This Month',
        value: controller.totalThisMonth,
        growth: 6.3,
        icon: Icons.calendar_today_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        sparkline: [20, 22, 25, 23, 28, 30, 35],
      ),
      _ExpenseKpiData(
        title: 'Total This Week',
        value: controller.totalThisWeek,
        growth: -4.2,
        icon: Icons.date_range_outlined,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        sparkline: [40, 38, 35, 30, 25, 20, 15],
      ),
      _ExpenseKpiData(
        title: 'Total Today',
        value: controller.totalToday,
        growth: 3.1,
        icon: Icons.today_outlined,
        gradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        sparkline: [10, 12, 15, 13, 18, 20, 25],
      ),
      _ExpenseKpiData(
        title: 'Pending Approvals',
        value: controller.pendingApprovals.toDouble(),
        growth: 0,
        icon: Icons.pending_actions_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        sparkline: [],
        isCurrency: false,
        isAlert: true,
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
        mainAxisExtent: 210, // Increased to prevent vertical overflow
      ),
      itemBuilder: (context, index) {
        return _ExpenseKpiCard(data: kpis[index])
            .animate()
            .fadeIn(delay: (70 * index).ms, duration: 420.ms)
            .slideY(begin: 0.14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _ExpenseKpiData {
  final String title;
  final double value;
  final double growth;
  final IconData icon;
  final List<Color> gradient;
  final List<double> sparkline;
  final bool isCurrency;
  final bool isAlert;

  const _ExpenseKpiData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.gradient,
    required this.sparkline,
    this.isCurrency = true,
    this.isAlert = false,
  });
}

class _ExpenseKpiCard extends StatelessWidget {
  final _ExpenseKpiData data;

  const _ExpenseKpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    if (data.isAlert) {
      return GlassPanel(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.value.toInt().toString(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('₹ 18,750.00', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: muted)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: data.gradient.first,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Prepare Return', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    }

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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.isCurrency
                            ? NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value)
                            : data.value.toInt().toString(),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
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
                          Text(data.title.contains('Week') ? 'vs last week' : data.title.contains('Today') ? 'vs yesterday' : 'vs last month', style: TextStyle(color: muted, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (data.sparkline.isNotEmpty) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  height: 30,
                  child: CustomPaint(
                    painter: _KpiSparklinePainter(points: data.sparkline, color: data.gradient.first),
                  ),
                ),
              ],
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

class _MainExpenseContent extends GetView<ExpenseController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassPanel(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ExpenseTabs(),
              const SizedBox(height: 18),
              _ExpenseFilterBar(),
              const SizedBox(height: 18),
              _ExpenseTable(),
              const SizedBox(height: 20),
              _TablePagination(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _ExpenseTrendChart(),
      ],
    );
  }
}

class _ExpenseTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'label': 'All Expenses', 'badge': 0},
      {'label': 'Pending Approval', 'badge': 5},
      {'label': 'Approved', 'badge': 0},
      {'label': 'Recurring Expenses', 'badge': 0},
      {'label': 'Bills & Receipts', 'badge': 0},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab['label'] == 'All Expenses';
          return Container(
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
            child: Row(
              children: [
                Text(
                  tab['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                if ((tab['badge'] as int) > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text('${tab['badge']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExpenseFilterBar extends GetView<ExpenseController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      hintText: 'Search expense, category, note...',
                      hintStyle: TextStyle(color: muted, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _FilterDropdown(label: 'All Categories', icon: Icons.category_outlined),
        const SizedBox(width: 12),
        const _FilterDropdown(label: 'All Payment Modes', icon: Icons.payment_outlined),
        const SizedBox(width: 12),
        const _FilterDropdown(label: 'Select Date', icon: Icons.calendar_today_outlined),
        const SizedBox(width: 12),
        const _ActionButton(icon: Icons.tune_rounded, label: 'Filters'),
        const SizedBox(width: 12),
        const _AddExpenseButton(),
      ],
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  const _AddExpenseButton();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () => Get.dialog(AddExpenseDialog()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_rounded, size: 18),
            SizedBox(width: 8),
            Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _FilterDropdown({required this.label, this.icon});

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
          if (icon != null) ...[Icon(icon, size: 18, color: muted), const SizedBox(width: 8)],
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted),
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
      height: 44,
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
        ],
      ),
    );
  }
}

class _ExpenseTable extends GetView<ExpenseController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['Date', 'Expense', 'Category', 'Payment Mode', 'Amount', 'Status', 'Action'];

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
                  flex: i == 1 ? 3 : i == 4 ? 2 : 2,
                  child: Text(
                    columns[i],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted),
                  ),
                ),
            ],
          ),
        ),
        Obx(() {
          final list = controller.filteredExpenses;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _ExpenseRow(expense: list[index]);
            },
          );
        }),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;

  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    // Mock fields for the missing data in schema
    final status = expense.amount > 10000 ? 'Pending' : (expense.amount > 5000 ? 'Rejected' : 'Approved');
    final statusColor = status == 'Approved' ? Colors.green : status == 'Pending' ? Colors.orange : Colors.red;
    final paymentMode = 'UPI';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
          // Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(expense.expenseDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(DateFormat('hh:mm a').format(expense.expenseDate), style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Expense Name
          Expanded(flex: 3, child: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          // Category
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(expense.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blue)),
              ),
            ),
          ),
          // Payment Mode
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.payment, size: 14),
                const SizedBox(width: 4),
                Text(paymentMode, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
          // Amount
          Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(expense.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
              ),
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _TableActionIcon(icon: Icons.visibility_outlined, onTap: () {}),
                _TableActionIcon(icon: Icons.more_vert_rounded, onTap: () {}),
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
  final VoidCallback onTap;
  
  const _TableActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.grey),
      ),
    );
  }
}

class _TablePagination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Showing 1 to 10 of 156 results', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const Spacer(),
        const _PaginationButton(icon: Icons.chevron_left_rounded),
        const SizedBox(width: 8),
        const _PageNumber(number: 1, active: true),
        const _PageNumber(number: 2),
        const _PageNumber(number: 3),
        const _PageNumber(number: 4),
        const _PageNumber(number: 5),
        const Text('...', style: TextStyle(color: Colors.grey)),
        const _PageNumber(number: 16),
        const SizedBox(width: 8),
        const _PaginationButton(icon: Icons.chevron_right_rounded),
        const SizedBox(width: 16),
        const Text('Rows per page:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
          child: Row(children: const [Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), SizedBox(width: 8), Icon(Icons.keyboard_arrow_down_rounded, size: 16)]),
        ),
      ],
    );
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

class _ExpenseTrendChart extends StatelessWidget {
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
              const Expanded(child: Text('Expense Trend', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              _LegendDot(color: Colors.blue, label: 'This Month'),
              SizedBox(width: 16),
              _LegendDot(color: Colors.grey, label: 'Last Month', dashed: true),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 31,
                minY: 0,
                maxY: 40,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 10,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 5,
                      getTitlesWidget: (v, m) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${v.toInt()} May', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(1, 12), FlSpot(5, 14), FlSpot(10, 18), FlSpot(15, 16), FlSpot(20, 24), FlSpot(25, 22), FlSpot(31, 28)],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(1, 10), FlSpot(5, 12), FlSpot(10, 15), FlSpot(15, 14), FlSpot(20, 20), FlSpot(25, 18), FlSpot(31, 22)],
                    isCurved: true,
                    color: Colors.grey.shade400,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendDot({required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 18 : 10,
          height: dashed ? 2 : 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(dashed ? 0 : 5)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
      ],
    );
  }
}

class _ExpenseRightRail extends StatelessWidget {
  const _ExpenseRightRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ExpenseOverviewChart(),
        SizedBox(height: 18),
        _TopExpenseCategories(),
      ],
    );
  }
}

class _ExpenseOverviewChart extends GetView<ExpenseController> {
  const _ExpenseOverviewChart();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final data = controller.categoryTotals;
    final total = data.values.fold(0.0, (s, e) => s + e);

    return GlassPanel(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Expense Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              const _SmallDropdown(label: 'This Month'),
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
                      PieChartSectionData(color: Colors.blue, value: 35, title: '', radius: 25),
                      PieChartSectionData(color: Colors.green, value: 25, title: '', radius: 25),
                      PieChartSectionData(color: Colors.orange, value: 15, title: '', radius: 25),
                      PieChartSectionData(color: Colors.red, value: 10, title: '', radius: 25),
                      PieChartSectionData(color: Colors.purple, value: 8, title: '', radius: 25),
                      PieChartSectionData(color: Colors.grey, value: 7, title: '', radius: 25),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)),
                    Text(NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ').format(total > 0 ? total : 42350), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Text('Category Summary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const _CategoryLegend(label: 'Rent', amount: 14750, color: Colors.blue, percentage: 35, icon: Icons.storefront),
          const _CategoryLegend(label: 'Salaries', amount: 10575, color: Colors.green, percentage: 25, icon: Icons.people_outline),
          const _CategoryLegend(label: 'Utilities', amount: 6345, color: Colors.orange, percentage: 15, icon: Icons.bolt),
          const _CategoryLegend(label: 'Marketing', amount: 4235, color: Colors.red, percentage: 10, icon: Icons.campaign_outlined),
          const _CategoryLegend(label: 'Transport', amount: 3380, color: Colors.purple, percentage: 8, icon: Icons.local_shipping_outlined),
          const _CategoryLegend(label: 'Others', amount: 3065, color: Colors.grey, percentage: 7, icon: Icons.more_horiz),
        ],
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final double percentage;
  final IconData icon;

  const _CategoryLegend({required this.label, required this.amount, required this.color, required this.percentage, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
          Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text('${percentage.toInt()}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _TopExpenseCategories extends StatelessWidget {
  const _TopExpenseCategories();

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
              const Expanded(child: Text('Top Expense Categories', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 12),
          const _ProgressBarItem(label: 'Rent', amount: 14750, progress: 1.0, color: Colors.blue),
          const _ProgressBarItem(label: 'Salaries', amount: 10575, progress: 0.75, color: Colors.green),
          const _ProgressBarItem(label: 'Utilities', amount: 6345, progress: 0.5, color: Colors.orange),
          const _ProgressBarItem(label: 'Marketing', amount: 4235, progress: 0.35, color: Colors.red),
          const _ProgressBarItem(label: 'Transport', amount: 3380, progress: 0.25, color: Colors.purple),
        ],
      ),
    );
  }
}

class _ProgressBarItem extends StatelessWidget {
  final String label;
  final double amount;
  final double progress;
  final Color color;

  const _ProgressBarItem({required this.label, required this.amount, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 0).format(amount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
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
