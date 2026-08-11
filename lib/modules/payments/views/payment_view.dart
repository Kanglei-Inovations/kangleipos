import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_panel.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }

    return MainLayout(
      title: 'Payments & Cashbook',
      headerAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => controller.refreshData(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Obx(() {
            if (controller.isLoading.value && controller.transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PaymentKpiGrid(width: width),
                    const SizedBox(height: 18),
                    _FilterAndSearchBar(controller: controller),
                    const SizedBox(height: 18),
                    _PaymentTransactionsTable(controller: controller),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _PaymentKpiGrid extends GetView<PaymentController> {
  final double width;
  const _PaymentKpiGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final isDesktop = width >= 1280;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: isDesktop ? (width - 48) / 4 : (width - 16) / 2,
          child: _KpiCard(
            title: 'Remaining Net Balance',
            value: '₹ ${NumberFormat('#,##,##0.00').format(controller.remainingNetBalance)}',
            subtitle: 'Net Cashflow (IN - OUT)',
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF4F46E5),
            isPrimary: true,
          ),
        ),
        SizedBox(
          width: isDesktop ? (width - 48) / 4 : (width - 16) / 2,
          child: _KpiCard(
            title: 'Total Payment IN',
            value: '₹ ${NumberFormat('#,##,##0.00').format(controller.totalPaymentIn)}',
            subtitle: 'Sales & Customer Debt Settlements',
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.successColor,
          ),
        ),
        SizedBox(
          width: isDesktop ? (width - 48) / 4 : (width - 16) / 2,
          child: _KpiCard(
            title: 'Total Payment OUT',
            value: '₹ ${NumberFormat('#,##,##0.00').format(controller.totalPaymentOut)}',
            subtitle: 'Vendor Purchases & Operating Expenses',
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.dangerColor,
          ),
        ),
        SizedBox(
          width: isDesktop ? (width - 48) / 4 : (width - 16) / 2,
          child: _KpiCard(
            title: 'Cash vs Digital',
            value: 'Cash: ₹${controller.cashBalance.toStringAsFixed(0)}',
            subtitle: 'UPI: ₹${controller.upiBalance.toStringAsFixed(0)} | Card: ₹${controller.cardBalance.toStringAsFixed(0)}',
            icon: Icons.point_of_sale_rounded,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  final bool isPrimary;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isPrimary ? color : null)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FilterAndSearchBar extends StatelessWidget {
  final PaymentController controller;
  const _FilterAndSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Obx(() {
            return Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All Transactions',
                  isSelected: controller.selectedTypeFilter.value == 'ALL',
                  onTap: () => controller.selectedTypeFilter.value = 'ALL',
                ),
                _FilterChip(
                  label: 'Payment IN (Inflow)',
                  isSelected: controller.selectedTypeFilter.value == 'PAYMENT_IN',
                  onTap: () => controller.selectedTypeFilter.value = 'PAYMENT_IN',
                  activeColor: AppTheme.successColor,
                ),
                _FilterChip(
                  label: 'Payment OUT (Outflow)',
                  isSelected: controller.selectedTypeFilter.value == 'PAYMENT_OUT',
                  onTap: () => controller.selectedTypeFilter.value = 'PAYMENT_OUT',
                  activeColor: AppTheme.dangerColor,
                ),
              ],
            );
          }),
          const Spacer(),
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search Party, ID, Ref...',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = activeColor ?? const Color(0xFF4F46E5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : chipColor,
          ),
        ),
      ),
    );
  }
}

class _PaymentTransactionsTable extends StatelessWidget {
  final PaymentController controller;
  const _PaymentTransactionsTable({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Transactions Ledger', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Obx(() => Text('${controller.filteredTransactions.length} Transactions', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final list = controller.filteredTransactions;
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text('No payment transactions found.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              );
            }

            return Table(
              columnWidths: const {
                0: FlexColumnWidth(1.4),
                1: FlexColumnWidth(1.6),
                2: FlexColumnWidth(1.4),
                3: FlexColumnWidth(1.8),
                4: FlexColumnWidth(1.2),
                5: FlexColumnWidth(1.2),
                6: FlexColumnWidth(1.4),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)))),
                  children: const [
                    _HeaderCell('Date & Time'),
                    _HeaderCell('Transaction ID'),
                    _HeaderCell('Category'),
                    _HeaderCell('Party / Description'),
                    _HeaderCell('Mode'),
                    _HeaderCell('Type'),
                    _HeaderCell('Amount', alignRight: true),
                  ],
                ),
                ...list.map((t) {
                  final isPaymentIn = t.type == 'PAYMENT_IN';
                  return TableRow(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)))),
                    children: [
                      _TableCell(DateFormat('MMM dd, hh:mm a').format(t.date)),
                      _TableCell(t.id, isBold: true),
                      _TableCell(t.category),
                      _TableCell(t.partyName),
                      _TableCellBadge(t.paymentMode, Colors.blue),
                      _TableCellBadge(isPaymentIn ? 'IN' : 'OUT', isPaymentIn ? AppTheme.successColor : AppTheme.dangerColor),
                      _TableCell(
                        '${isPaymentIn ? "+" : "-"} ₹${NumberFormat('#,##,##0.00').format(t.amount)}',
                        alignRight: true,
                        isBold: true,
                        textColor: isPaymentIn ? AppTheme.successColor : AppTheme.dangerColor,
                      ),
                    ],
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool alignRight;
  const _HeaderCell(this.text, {this.alignRight = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool alignRight;
  final bool isBold;
  final Color? textColor;

  const _TableCell(this.text, {this.alignRight = false, this.isBold = false, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class _TableCellBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _TableCellBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
        ),
      ),
    );
  }
}
