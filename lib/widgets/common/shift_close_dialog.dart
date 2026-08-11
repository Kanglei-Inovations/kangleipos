import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database.dart';

Future<void> showDayEndZReportDialog(BuildContext context) async {
  final db = Get.find<AppDatabase>();
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  // Calculate today's cash sales
  final invoices = await db.select(db.invoices).get();
  final todayInvoices = invoices.where((i) => 
    i.createdAt.isAfter(startOfDay) && i.status == 'PAID'
  ).toList();
  
  final todayCashSales = todayInvoices
    .where((i) => i.paymentMethod == 'CASH')
    .fold(0.0, (sum, i) => sum + i.grandTotal);
    
  final todayTotalSales = todayInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);
  
  // Calculate today's expenses
  final expenses = await db.select(db.expenses).get();
  final todayExpenses = expenses
    .where((e) => e.expenseDate.isAfter(startOfDay))
    .fold(0.0, (sum, e) => sum + e.amount);

  const double openingFloat = 2000.0;
  final double expectedCash = openingFloat + todayCashSales - todayExpenses;
  
  final TextEditingController countedController = TextEditingController(text: expectedCash.toStringAsFixed(2));
  final RxDouble countedCash = expectedCash.obs;
  final RxDouble variance = 0.0.obs;

  showDialog(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final isDark = theme.brightness == Brightness.dark;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fact_check_rounded, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shift Close & Z-Report', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text('Daily Cash Register Reconciliation', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _StatRow('Date & Time', DateFormat('MMM dd, yyyy - hh:mm a').format(now)),
                      const Divider(height: 16),
                      _StatRow('Opening Cash Float', '₹ ${NumberFormat('#,##,##0.00').format(openingFloat)}'),
                      _StatRow('Today Cash Sales', '₹ ${NumberFormat('#,##,##0.00').format(todayCashSales)}', color: AppTheme.successColor),
                      _StatRow('Today Expenses (Cash Out)', '- ₹ ${NumberFormat('#,##,##0.00').format(todayExpenses)}', color: AppTheme.dangerColor),
                      const Divider(height: 16),
                      _StatRow('Expected Cash in Drawer', '₹ ${NumberFormat('#,##,##0.00').format(expectedCash)}', isBold: true),
                      _StatRow('Total Gross Revenue (All Modes)', '₹ ${NumberFormat('#,##,##0.00').format(todayTotalSales)}', isMuted: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Counted Physical Cash in Drawer:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: countedController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0.00',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val) ?? 0.0;
                    countedCash.value = parsed;
                    variance.value = parsed - expectedCash;
                  },
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final v = variance.value;
                  final isShort = v < 0;
                  final isExact = v.abs() < 0.01;
                  Color vColor = isExact ? AppTheme.successColor : (isShort ? AppTheme.dangerColor : Colors.blue);
                  String vText = isExact ? 'Exact Balance (No Discrepancy)' : (isShort ? 'Shortage: -₹ ${v.abs().toStringAsFixed(2)}' : 'Overage: +₹ ${v.abs().toStringAsFixed(2)}');

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: vColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: vColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(isExact ? Icons.check_circle_rounded : (isShort ? Icons.warning_rounded : Icons.info_rounded), color: vColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vText,
                            style: TextStyle(color: vColor, fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.snackbar(
                'Shift Closed',
                'Z-Report generated successfully. Total Drawer Cash: ₹${countedCash.value.toStringAsFixed(2)}',
                backgroundColor: AppTheme.successColor.withValues(alpha: 0.9),
                colorText: Colors.white,
              );
            },
            icon: const Icon(Icons.print_rounded, size: 16),
            label: const Text('Close Shift & Print Z-Report', style: TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      );
    },
  );
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  final bool isMuted;

  const _StatRow(this.label, this.value, {this.color, this.isBold = false, this.isMuted = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMuted ? 11 : 12,
              color: isMuted ? Colors.grey : theme.textTheme.bodyMedium?.color,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              color: color ?? theme.textTheme.bodyLarge?.color,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
