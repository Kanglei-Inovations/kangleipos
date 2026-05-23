import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/customer_controller.dart';
import 'add_customer_dialog.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Customers',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isDesktop = width >= 1280;

          return Obx(() {
            if (controller.isLoading.value && controller.customers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CustomerKpiGrid(width: width),
                  const SizedBox(height: 18),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _MainCustomerContent()),
                        const SizedBox(width: 18),
                        const Expanded(flex: 3, child: _CustomerDetailSidebar()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _MainCustomerContent(),
                        const SizedBox(height: 18),
                        const _CustomerDetailSidebar(),
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

class _CustomerKpiGrid extends GetView<CustomerController> {
  final double width;

  const _CustomerKpiGrid({required this.width});

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
      _CustomerKpiData(
        title: 'Total Customers',
        value: controller.totalCustomers.toDouble(),
        growth: 12.5,
        icon: Icons.people_alt_outlined,
        gradient: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      ),
      _CustomerKpiData(
        title: 'Active Customers',
        value: controller.activeCustomers.toDouble(),
        subtitle: '82.1% of total',
        icon: Icons.person_add_alt_1_outlined,
        gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
        isPercentage: true,
      ),
      _CustomerKpiData(
        title: 'Inactive Customers',
        value: controller.inactiveCustomers.toDouble(),
        subtitle: '17.9% of total',
        icon: Icons.person_off_outlined,
        gradient: [const Color(0xFF94A3B8), const Color(0xFF64748B)],
      ),
      _CustomerKpiData(
        title: 'Total Receivable',
        value: controller.totalReceivable,
        subtitle: 'From 42 customers',
        icon: Icons.account_balance_wallet_outlined,
        gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        isCurrency: true,
      ),
      _CustomerKpiData(
        title: 'Overdue Amount',
        value: controller.overdueAmount,
        subtitle: 'From 15 customers',
        icon: Icons.report_problem_outlined,
        gradient: [const Color(0xFFF43F5E), const Color(0xFFE11D48)],
        isCurrency: true,
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

class _CustomerKpiData {
  final String title;
  final double value;
  final double growth;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final bool isCurrency;
  final bool isPercentage;

  const _CustomerKpiData({
    required this.title,
    required this.value,
    this.growth = 0,
    this.subtitle = '',
    required this.icon,
    required this.gradient,
    this.isCurrency = false,
    this.isPercentage = false,
  });
}

class _KpiCard extends StatelessWidget {
  final _CustomerKpiData data;

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.gradient.first.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.gradient.first, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      data.isCurrency
                          ? NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(data.value)
                          : data.value.toInt().toString(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    if (data.growth > 0) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_upward_rounded, size: 10, color: Colors.green),
                      Text('${data.growth}%', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                if (data.subtitle.isNotEmpty)
                  Text(
                    data.subtitle,
                    style: TextStyle(fontSize: 10, color: data.isPercentage ? Colors.green : muted, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainCustomerContent extends GetView<CustomerController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassPanel(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _CustomerHeader(),
              const SizedBox(height: 18),
              _CustomerTabs(),
              const SizedBox(height: 18),
              _CustomerFilterBar(),
              const SizedBox(height: 18),
              _CustomerTable(),
              const SizedBox(height: 20),
              _TablePagination(),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _MonthlySalesOverview(),
      ],
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Text('Customers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        _HeaderButton(label: 'Add Customer', icon: Icons.add_rounded, color: const Color(0xFF4F46E5), isPrimary: true),
        const SizedBox(width: 12),
        _HeaderButton(label: 'Import Customers', icon: Icons.download_rounded),
        const SizedBox(width: 12),
        _IconCircleButton(icon: Icons.more_horiz),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isPrimary;

  const _HeaderButton({required this.label, required this.icon, this.color, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isPrimary ? (color ?? const Color(0xFF4F46E5)) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isPrimary ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: isPrimary ? Colors.white : Colors.black, fontSize: 13)),
        ],
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  const _IconCircleButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: Colors.grey),
    );
  }
}

class _CustomerTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabs = ['All Customers', 'Active', 'Inactive'];
    return Row(
      children: tabs.map((tab) {
        final isSelected = tab == 'All Customers';
        return Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2)),
          ),
          child: Text(tab, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey, fontSize: 14)),
        );
      }).toList(),
    );
  }
}

class _CustomerFilterBar extends GetView<CustomerController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Row(
      children: [
        Expanded(
          child: Container(
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
                      hintText: 'Search customers...',
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
        _FilterDropdown(label: 'All Status'),
        const SizedBox(width: 12),
        _FilterDropdown(label: 'All Groups'),
        const SizedBox(width: 12),
        _ActionButton(icon: Icons.tune_rounded, label: 'Filters'),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  const _FilterDropdown({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey)]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [Icon(icon, size: 18, color: Colors.grey), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey))]),
    );
  }
}

class _CustomerTable extends GetView<CustomerController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    final columns = ['Customer Name', 'Group', 'Phone', 'Total Receivable', 'Status', 'Action'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9)))),
          child: Row(
            children: [
              SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: i == 0 ? 3 : 2,
                  child: Row(
                    children: [
                      Text(columns[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: muted)),
                      if (i == 0) const Icon(Icons.unfold_more_rounded, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Obx(() {
          final list = controller.filteredCustomers;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return _CustomerRow(customer: list[index]);
            },
          );
        }),
      ],
    );
  }
}

class _CustomerRow extends GetView<CustomerController> {
  final Customer customer;
  const _CustomerRow({required this.customer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;
    
    final status = customer.balanceDue > 50000 ? 'Overdue' : (customer.balanceDue > 0 ? 'Active' : 'Inactive');
    final statusColor = status == 'Active' ? Colors.green : status == 'Overdue' ? Colors.red : Colors.grey;

    return Obx(() {
      final isSelected = controller.selectedCustomerForDetails.value?.id == customer.id;
      return GestureDetector(
        onTap: () => controller.selectedCustomerForDetails.value = customer,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.05) : Colors.transparent,
            border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              SizedBox(width: 30, child: Checkbox(value: false, onChanged: (v) {}, visualDensity: VisualDensity.compact)),
              // Name
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: Colors.indigo.withOpacity(0.1), child: Text(customer.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('CUST-${customer.id.substring(0, 4)}', style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Group
              Expanded(flex: 2, child: Text('Retailers', style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600))),
              // Phone
              Expanded(flex: 2, child: Text(customer.phone ?? '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              // Receivable
              Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(customer.balanceDue), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
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
                child: Row(children: [IconButton(icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey), onPressed: () {})]),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _TablePagination extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Showing 1 to 10 of 156 customers', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const Spacer(),
        _PaginationButton(icon: Icons.chevron_left_rounded),
        const SizedBox(width: 8),
        _PageNumber(number: 1, active: true),
        _PageNumber(number: 2),
        _PageNumber(number: 3),
        _PageNumber(number: 4),
        _PageNumber(number: 5),
        const Text('...', style: TextStyle(color: Colors.grey)),
        _PageNumber(number: 16),
        const SizedBox(width: 8),
        _PaginationButton(icon: Icons.chevron_right_rounded),
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

class _MonthlySalesOverview extends StatelessWidget {
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
              const Expanded(child: Text('Monthly Sales Overview', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              _SmallDropdown(label: 'This Year'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 200,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}K', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, m) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        return Text(months[v.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                barGroups: [80, 100, 120, 110, 150, 130, 140, 160, 90, 100, 70, 110].asMap().entries.map((e) {
                  return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.toDouble(), color: const Color(0xFF6366F1), width: 12, borderRadius: BorderRadius.circular(3))]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerDetailSidebar extends GetView<CustomerController> {
  const _CustomerDetailSidebar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customer = controller.selectedCustomerForDetails.value;
      if (customer == null) return const SizedBox.shrink();

      return GlassPanel(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: const Color(0xFF6366F1).withOpacity(0.1), child: Text(customer.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green))),
                        ],
                      ),
                      Text('CUST-${customer.id.substring(0, 4)}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                _HeaderButton(label: 'Edit', icon: Icons.edit_outlined),
              ],
            ),
            const SizedBox(height: 24),
            _ContactRow(icon: Icons.phone_outlined, text: customer.phone ?? '-'),
            const SizedBox(height: 12),
            _ContactRow(icon: Icons.email_outlined, text: customer.email ?? 'No Email'),
            const SizedBox(height: 12),
            _ContactRow(icon: Icons.location_on_outlined, text: customer.address ?? 'No Address'),
            const SizedBox(height: 12),
            _ContactRow(icon: Icons.assignment_outlined, text: 'GSTIN: ${customer.gstNumber ?? '-'}'),
            const SizedBox(height: 12),
            _ContactRow(icon: Icons.credit_card_outlined, text: 'Credit Limit: ₹ 1,00,000.00'),
            const SizedBox(height: 24),
            Row(
              children: [
                _MiniStat(label: 'Total Sales', amount: '₹ 12,75,430.00', color: Colors.black),
                _MiniStat(label: 'Total Paid', amount: '₹ 10,30,199.50', color: Colors.green),
                _MiniStat(label: 'Total Due', amount: '₹ 2,45,230.50', color: Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LastActivity(label: 'Last Invoice', no: 'INV-10058', date: 'May 20, 2025'),
                _LastActivity(label: 'Last Payment', no: 'PAY-10032', date: 'May 18, 2025'),
              ],
            ),
            const SizedBox(height: 24),
            _SidebarTabs(),
            const SizedBox(height: 20),
            _SidebarDetailRow(label: 'Customer Group', value: 'Retailers'),
            _SidebarDetailRow(label: 'Opening Balance', value: '₹ 0.00'),
            _SidebarDetailRow(label: 'Current Balance', value: '₹ 45,230.50', isBold: true, color: Colors.red),
            _SidebarDetailRow(label: 'Total Orders', value: '18'),
            _SidebarDetailRow(label: 'Total Invoices', value: '16'),
            _SidebarDetailRow(label: 'Total Payments', value: '14'),
            _SidebarDetailRow(label: 'Member Since', value: 'Jan 15, 2024'),
            _SidebarDetailRow(label: 'Created By', value: 'Admin User'),
            _SidebarDetailRow(label: 'Created On', value: 'Jan 15, 2024 10:30 AM'),
          ],
        ),
      );
    });
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 12), Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label, amount;
  final Color color;
  const _MiniStat({required this.label, required this.amount, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)), Text(amount, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color))]));
  }
}

class _LastActivity extends StatelessWidget {
  final String label, no, date;
  const _LastActivity({required this.label, required this.no, required this.date});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w700)), Text(no, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)), Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600))]);
  }
}

class _SidebarTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabs = ['Overview', 'Transactions', 'Invoices', 'Payments', 'Notes'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        final isSelected = tab == 'Overview';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent, width: 2))),
          child: Text(tab, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? const Color(0xFF4F46E5) : Colors.grey, fontSize: 11)),
        );
      }).toList(),
    );
  }
}

class _SidebarDetailRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? color;
  const _SidebarDetailRow({required this.label, required this.value, this.isBold = false, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color ?? Colors.black)),
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
