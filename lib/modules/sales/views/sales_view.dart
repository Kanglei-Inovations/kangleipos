import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/sales_controller.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sales',
      headerAction: ElevatedButton.icon(
        onPressed: () => Get.toNamed(AppRoutes.POS),
        icon: const Icon(Icons.point_of_sale_rounded, size: 18),
        label: const Text(
          'POS / Billing',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.sales.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMainContent(context)),
            ],
          ),
        );
      }),
    );
  }


  Widget _buildMainContent(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 768) {
        return const _MobileTransactionsView();
      }
      if (constraints.maxWidth < 1200) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _RecentInvoicesTable(),
              const SizedBox(height: 16),
              _SalesByCategoryPanel(),
              const SizedBox(height: 16),
              _SalesSummaryPanel(),
              const SizedBox(height: 16),
              _TopCustomersPanel(),
              const SizedBox(height: 16),
              _ChartBox(
                title: 'Sales Return Summary',
                height: 220,
                dropdownText: 'This Month',
                child: _SalesReturnChart(),
              ),
            ],
          ),
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _RecentInvoicesTable(),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 360,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  _SalesByCategoryPanel(),
                  const SizedBox(height: 16),
                  _SalesSummaryPanel(),
                  const SizedBox(height: 16),
                  _TopCustomersPanel(),
                  const SizedBox(height: 16),
                  _ChartBox(
                    title: 'Sales Return Summary',
                    height: 220,
                    dropdownText: 'This Month',
                    child: _SalesReturnChart(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ChartBox extends StatelessWidget {
  final String title;
  final Widget child;
  final double height;
  final String? dropdownText;

  const _ChartBox({
    required this.title,
    required this.child,
    required this.height,
    this.dropdownText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (dropdownText != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(dropdownText!, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: theme.textTheme.bodySmall?.color, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.more_horiz, color: theme.textTheme.bodySmall?.color?.withOpacity(0.4), size: 20),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RecentInvoicesTable extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sales Invoice List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: () => controller.refreshAllData(),
                    child: const Text('Refresh', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(width: 6),
                        const Text(
                          'May 01, 2025 - May 24, 2025',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: theme.textTheme.bodySmall?.color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Sales Filters Bar (MasterFilterBar Style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: controller.updateSearch,
                      decoration: InputDecoration(
                        hintText: 'Search Invoice #, Customer...',
                        prefixIcon: Icon(Icons.search, color: theme.textTheme.bodySmall?.color),
                        filled: true,
                        fillColor: theme.dividerColor.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => _buildFilterItem(
                    context,
                    Icons.person_outline_rounded,
                    controller.selectedCustomerId.value,
                    ['All Customers', ...controller.customers.map((c) => c.name)],
                    (val) => controller.updateCustomerFilter(val!),
                  )),
                  const SizedBox(width: 12),
                  Obx(() => _buildFilterItem(
                    context,
                    Icons.payments_outlined,
                    controller.selectedPaymentMethod.value,
                    ['All Payment', 'CASH', 'UPI', 'CARD', 'SPLIT'],
                    (val) => controller.updatePaymentFilter(val!),
                  )),
                  const SizedBox(width: 12),
                  Obx(() => _buildFilterItem(
                    context,
                    Icons.info_outline_rounded,
                    controller.selectedStatus.value,
                    ['All Status', 'PAID', 'UNPAID', 'HOLD', 'RETURNED'],
                    (val) => controller.updateStatusFilter(val!),
                  )),
                  const SizedBox(width: 12),
                  Obx(() => _buildFilterItem(
                    context,
                    Icons.calendar_today_outlined,
                    controller.selectedDateRange.value,
                    ['Today', 'Yesterday', 'Last 7 Days', 'This Month', 'All Time'],
                    (val) => controller.updateDateFilter(val!),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final sales = controller.paginatedSales;
                if (sales.isEmpty && !controller.isLoading.value) {
                  return const Center(child: Text('No sales found matching filters.'));
                }
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(theme.dividerColor.withOpacity(0.05)),
                        horizontalMargin: 24,
                        columnSpacing: 24,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 48,
                        columns: [
                          DataColumn(label: Text('Invoice No.', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                          DataColumn(label: Text('Customer', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                          DataColumn(label: Text('Date', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                          DataColumn(label: Text('Payment', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                          DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                          DataColumn(label: Text('Action', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                        ],
                        rows: sales.map((inv) {
                          return DataRow(cells: [
                            DataCell(Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataCell(Builder(builder: (ctx) {
                              final custName = controller.customers
                                  .firstWhereOrNull((c) => c.id == inv.customerId)?.name;
                              return Text(
                                custName ?? (inv.customerId != null ? 'Customer' : 'Walk-in'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              );
                            })),
                            DataCell(Text(DateFormat('MMM dd, HH:mm').format(inv.createdAt), style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color))),
                            DataCell(Text('₹ ${inv.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            DataCell(_buildBadge(inv.paymentMethod, _getPaymentColor(inv.paymentMethod))),
                            DataCell(_buildBadge(inv.status, _getStatusColor(inv.status))),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove_red_eye_outlined, size: 16), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                const SizedBox(width: 8),
                                IconButton(icon: const Icon(Icons.print_outlined, size: 16), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                const SizedBox(width: 8),
                                IconButton(icon: const Icon(Icons.more_vert, size: 16), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    'Showing ${(controller.currentPage.value - 1) * controller.rowsPerPage.value + 1} to ${((controller.currentPage.value - 1) * controller.rowsPerPage.value + controller.paginatedSales.length)} of ${controller.filteredSales.length} entries', 
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)
                  )),
                  Row(
                    children: [
                      _buildPageBtn(context, '<', false, onTap: () => controller.previousPage()),
                      Obx(() => Text(' Page ${controller.currentPage.value} of ${controller.totalPages} ', style: const TextStyle(fontSize: 12))),
                      _buildPageBtn(context, '>', false, onTap: () => controller.nextPage()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterItem(BuildContext context, IconData icon, String current, List<String> options, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(current) ? current : options.first,
              onChanged: onChanged,
              icon: Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textTheme.bodySmall?.color),
              style: TextStyle(fontSize: 12, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
              dropdownColor: theme.cardColor,
              items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String method) {
    switch (method.toUpperCase()) {
      case 'CASH': return Colors.green;
      case 'UPI': return Colors.purple;
      case 'CARD': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID': return Colors.green;
      case 'RETURNED': return Colors.red;
      case 'HOLD': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildPageBtn(BuildContext context, String text, bool active, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: active ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(text, style: TextStyle(color: active ? Colors.white : theme.textTheme.bodyLarge?.color, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _SalesByCategoryPanel extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.categorySales.isEmpty) {
              return const Center(child: Text('No data', style: TextStyle(fontSize: 12)));
            }
            final total = controller.totalSalesAmount.value;
            return Column(
              children: controller.categorySales.entries.map((e) {
                final pct = total > 0 ? (e.value / total) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildCategoryItem(context, Icons.category_outlined, e.key, '₹ ${e.value.toStringAsFixed(2)}', '${(pct * 100).toStringAsFixed(0)}%', Colors.blue, pct),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String title, String amt, String pct, Color color, double progress) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text(amt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 4, borderRadius: BorderRadius.circular(2)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(pct, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
      ],
    );
  }
}

class _SalesSummaryPanel extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Obx(() => _SummaryRow(label: 'Total Sales', value: '₹ ${controller.totalSalesAmount.value.toStringAsFixed(2)}', icon: Icons.shopping_cart_outlined, color: Colors.blue)),
          Obx(() => _SummaryRow(label: 'Total Profit', value: '₹ ${controller.totalProfitAmount.value.toStringAsFixed(2)}', icon: Icons.account_balance_wallet_outlined, color: Colors.green)),
          Obx(() => _SummaryRow(label: 'Total Orders', value: controller.totalOrdersCount.value.toString(), icon: Icons.receipt_long_outlined, color: Colors.purpleAccent)),
          _SummaryRow(label: 'Avg Order Value', value: '₹ ${(controller.totalOrdersCount.value > 0 ? controller.totalSalesAmount.value / controller.totalOrdersCount.value : 0.0).toStringAsFixed(2)}', icon: Icons.shopping_bag_outlined, color: Colors.orange, isLast: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLast;
  const _SummaryRow({required this.label, required this.value, required this.icon, required this.color, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 16), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: color)), const SizedBox(width: 12), Text(label, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500)), const Spacer(), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
  }
}

class _TopCustomersPanel extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Customers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.topCustomers.isEmpty) {
              return const Center(child: Text('No data', style: TextStyle(fontSize: 12)));
            }
            return Column(
              children: controller.topCustomers.entries.map((e) => _CustomerRow(context, name: e.key, amount: '₹ ${e.value.toStringAsFixed(2)}', initial: e.key[0].toUpperCase(), color: Colors.blueAccent)).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final BuildContext context;
  final String name;
  final String amount;
  final String initial;
  final Color color;
  final bool isLast;
  const _CustomerRow(this.context, {required this.name, required this.amount, required this.initial, required this.color, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 16), child: Row(children: [CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.1), child: Text(initial, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))), const SizedBox(width: 12), Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)), const Spacer(), Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
  }
}

class _SalesReturnChart extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() => Row(
      children: [
        Expanded(
          flex: 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 35,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(color: Colors.redAccent, value: controller.totalReturnsAmount.value, radius: 15, showTitle: false),
                    PieChartSectionData(color: theme.dividerColor.withOpacity(0.1), value: (controller.totalSalesAmount.value - controller.totalReturnsAmount.value).clamp(1.0, double.infinity), radius: 15, showTitle: false),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Returns', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 10)),
                  Text('₹ ${controller.totalReturnsAmount.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildReturnStatRow(context, 'Return Orders', controller.totalReturnOrdersCount.value.toString()),
              const Divider(height: 16),
              _buildReturnStatRow(context, 'Return Amount', '₹ ${controller.totalReturnsAmount.value.toStringAsFixed(2)}'),
              const Divider(height: 16),
              _buildReturnStatRow(context, '% of Sales', '${(controller.totalSalesAmount.value > 0 ? (controller.totalReturnsAmount.value / controller.totalSalesAmount.value * 100) : 0.0).toStringAsFixed(2)}%'),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildReturnStatRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]);
  }
}

// ─────────────────────────────────────────────────────────
// MOBILE TRANSACTIONS VIEW (Matching Screen 5)
// ─────────────────────────────────────────────────────────
class _MobileTransactionsView extends StatefulWidget {
  const _MobileTransactionsView();

  @override
  State<_MobileTransactionsView> createState() => _MobileTransactionsViewState();
}

class _MobileTransactionItem {
  final String id;
  final String date;
  final String partyName;
  final double amount;
  final String type; // 'Sale', 'Purchase', 'Expense', 'Cash In', 'Cash Out'
  final String paymentMethod;
  final String status;
  final dynamic rawData;

  const _MobileTransactionItem({
    required this.id,
    required this.date,
    required this.partyName,
    required this.amount,
    required this.type,
    required this.paymentMethod,
    required this.status,
    this.rawData,
  });
}

class _MobileTransactionsViewState extends State<_MobileTransactionsView> {
  String _selectedFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _filters = ['All', 'Sales', 'Purchase', 'Expenses', 'Cash In', 'Cash Out'];
  
  List<_MobileTransactionItem> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final db = Get.find<AppDatabase>();
      final invoices = await db.select(db.invoices).get();
      final purchases = await db.select(db.purchases).get();
      final expenses = await db.select(db.expenses).get();
      final customers = await db.select(db.customers).get();
      final suppliers = await db.select(db.suppliers).get();

      final custMap = {for (var c in customers) c.id: c.name};
      final suppMap = {for (var s in suppliers) s.id: s.name};

      final List<_MobileTransactionItem> items = [];

      for (var inv in invoices) {
        items.add(_MobileTransactionItem(
          id: inv.invoiceNumber,
          date: DateFormat('dd MMM, hh:mm a').format(inv.createdAt),
          partyName: custMap[inv.customerId] ?? 'Walk-in Customer',
          amount: inv.grandTotal,
          type: 'Sale',
          paymentMethod: inv.paymentMethod,
          status: inv.status,
          rawData: inv,
        ));
      }

      for (var pur in purchases) {
        items.add(_MobileTransactionItem(
          id: 'BILL-${pur.purchaseNumber}',
          date: DateFormat('dd MMM, hh:mm a').format(pur.purchaseDate),
          partyName: suppMap[pur.supplierId] ?? 'Supplier Vendor',
          amount: pur.grandTotal,
          type: 'Purchase',
          paymentMethod: 'Bank / Cash',
          status: pur.status,
          rawData: pur,
        ));
      }

      for (var exp in expenses) {
        final shortId = exp.id.length > 5 ? exp.id.substring(0, 5) : exp.id;
        items.add(_MobileTransactionItem(
          id: 'EXP-$shortId',
          date: DateFormat('dd MMM, hh:mm a').format(exp.expenseDate),
          partyName: exp.description.isNotEmpty ? exp.description : exp.category,
          amount: exp.amount,
          type: 'Expense',
          paymentMethod: 'Cash',
          status: 'PAID',
          rawData: exp,
        ));
      }

      items.sort((a, b) => b.id.compareTo(a.id));
      if (mounted) {
        setState(() {
          _allTransactions = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_MobileTransactionItem> get _filteredTransactions {
    return _allTransactions.where((t) {
      if (_selectedFilter == 'Sales' && t.type != 'Sale') return false;
      if (_selectedFilter == 'Purchase' && t.type != 'Purchase') return false;
      if (_selectedFilter == 'Expenses' && t.type != 'Expense') return false;
      if (_selectedFilter == 'Cash In' && t.type != 'Cash In' && t.type != 'Sale') return false;
      if (_selectedFilter == 'Cash Out' && t.type != 'Cash Out' && t.type != 'Purchase' && t.type != 'Expense') return false;

      final query = _searchCtrl.text.toLowerCase().trim();
      if (query.isNotEmpty) {
        return t.id.toLowerCase().contains(query) ||
            t.partyName.toLowerCase().contains(query) ||
            t.amount.toString().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Chips Bar (Horizontal scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = filter),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4F46E5) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4F46E5) : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Search Bar & Filter Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF4F46E5)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Transactions List
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: isDark ? Colors.white24 : Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('No transactions found', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500], fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredTransactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _filteredTransactions[index];
                  return _buildTransactionCard(item, isDark);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(_MobileTransactionItem item, bool isDark) {
    Color badgeColor;
    Color badgeBg;
    if (item.type == 'Sale' || item.type == 'Cash In') {
      badgeColor = const Color(0xFF10B981);
      badgeBg = const Color(0xFF10B981).withValues(alpha: 0.12);
    } else if (item.type == 'Purchase') {
      badgeColor = const Color(0xFFF59E0B);
      badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
    } else {
      badgeColor = const Color(0xFFEF4444);
      badgeBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
    }

    return InkWell(
      onTap: () => _showDetailSheet(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.id,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.partyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹ ${NumberFormat('#,##,###.00').format(item.amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: badgeColor, size: 5),
                      const SizedBox(width: 4),
                      Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(_MobileTransactionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.id,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('Date & Time', item.date, isDark),
              _buildDetailRow('Party / Contact', item.partyName, isDark),
              _buildDetailRow('Payment Mode', item.paymentMethod, isDark),
              _buildDetailRow('Status', item.status, isDark),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                  Text(
                    '₹ ${NumberFormat('#,##,###.00').format(item.amount)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Close', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : const Color(0xFF64748B))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
