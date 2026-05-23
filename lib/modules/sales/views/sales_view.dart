import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/sales_controller.dart';
import '../../products_master/widgets/master_filter_bar.dart';

class SalesView extends GetView<SalesController> {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Sales',
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
      if (constraints.maxWidth < 1200) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              physics: const BouncingScrollPhysics(),
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
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (dropdownText != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(dropdownText!, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
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
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 6),
                        const Text(
                          'May 01, 2025 - May 24, 2025',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade700),
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
                      decoration: const InputDecoration(
                        hintText: 'Search Invoice #, Customer...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Color(0xFFF9FAFB),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => _buildFilterItem(
                    Icons.person_outline_rounded,
                    controller.selectedCustomerId.value,
                    ['All Customers', ...controller.customers.map((c) => c.name)],
                    (val) => controller.updateCustomerFilter(val!),
                  )),
                  const SizedBox(width: 12),
                  Obx(() => _buildFilterItem(
                    Icons.payments_outlined,
                    controller.selectedPaymentMethod.value,
                    ['All Payment', 'CASH', 'UPI', 'CARD', 'SPLIT'],
                    (val) => controller.updatePaymentFilter(val!),
                  )),
                  const SizedBox(width: 12),
                  Obx(() => _buildFilterItem(
                    Icons.info_outline_rounded,
                    controller.selectedStatus.value,
                    ['All Status', 'PAID', 'UNPAID', 'HOLD', 'RETURNED'],
                    (val) => controller.updateStatusFilter(val!),
                  )),
                  const SizedBox(width: 12),
                  Obx(() => _buildFilterItem(
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
                  physics: const BouncingScrollPhysics(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth - 24),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                        horizontalMargin: 24,
                        columnSpacing: 24,
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 48,
                        columns: const [
                          DataColumn(label: Text('Invoice No.', style: TextStyle(fontSize: 12, color: Colors.black54))),
                          DataColumn(label: Text('Customer', style: TextStyle(fontSize: 12, color: Colors.black54))),
                          DataColumn(label: Text('Date', style: TextStyle(fontSize: 12, color: Colors.black54))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontSize: 12, color: Colors.black54))),
                          DataColumn(label: Text('Payment', style: TextStyle(fontSize: 12, color: Colors.black54))),
                          DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, color: Colors.black54))),
                          DataColumn(label: Text('Action', style: TextStyle(fontSize: 12, color: Colors.black54))),
                        ],
                        rows: sales.map((inv) {
                          return DataRow(cells: [
                            DataCell(Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataCell(Text(inv.customerId ?? 'Walk-in', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                            DataCell(Text(DateFormat('MMM dd, HH:mm').format(inv.createdAt), style: const TextStyle(fontSize: 12, color: Colors.black54))),
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
                    style: const TextStyle(fontSize: 11, color: Colors.black54)
                  )),
                  Row(
                    children: [
                      _buildPageBtn('<', false, onTap: () => controller.previousPage()),
                      Obx(() => Text(' Page ${controller.currentPage.value} of ${controller.totalPages} ', style: const TextStyle(fontSize: 12))),
                      _buildPageBtn('>', false, onTap: () => controller.nextPage()),
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

  Widget _buildFilterItem(IconData icon, String current, List<String> options, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(current) ? current : options.first,
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
              style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
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

  Widget _buildPageBtn(String text, bool active, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: active ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                  child: _buildCategoryItem(Icons.category_outlined, e.key, '₹ ${e.value.toStringAsFixed(2)}', '${(pct * 100).toStringAsFixed(0)}%', Colors.blue, pct),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, String amt, String pct, Color color, double progress) {
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
        Text(pct, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}

class _SalesSummaryPanel extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
    return Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 16), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: color)), const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)), const Spacer(), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
  }
}

class _TopCustomersPanel extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
              children: controller.topCustomers.entries.map((e) => _CustomerRow(name: e.key, amount: '₹ ${e.value.toStringAsFixed(2)}', initial: e.key[0].toUpperCase(), color: Colors.blueAccent)).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final String name;
  final String amount;
  final String initial;
  final Color color;
  final bool isLast;
  const _CustomerRow({required this.name, required this.amount, required this.initial, required this.color, this.isLast = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 16), child: Row(children: [CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.1), child: Text(initial, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold))), const SizedBox(width: 12), Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)), const Spacer(), Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))]));
  }
}

class _SalesReturnChart extends GetView<SalesController> {
  @override
  Widget build(BuildContext context) {
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
                    PieChartSectionData(color: Colors.grey.shade200, value: (controller.totalSalesAmount.value - controller.totalReturnsAmount.value).clamp(1.0, double.infinity), radius: 15, showTitle: false),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Returns', style: TextStyle(color: Colors.black54, fontSize: 10)),
                  Text('₹ ${controller.totalReturnsAmount.value.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
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
              _buildReturnStatRow('Return Orders', controller.totalReturnOrdersCount.value.toString()),
              const Divider(height: 16),
              _buildReturnStatRow('Return Amount', '₹ ${controller.totalReturnsAmount.value.toStringAsFixed(2)}'),
              const Divider(height: 16),
              _buildReturnStatRow('% of Sales', '${(controller.totalSalesAmount.value > 0 ? (controller.totalReturnsAmount.value / controller.totalSalesAmount.value * 100) : 0.0).toStringAsFixed(2)}%'),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildReturnStatRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)), Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87))]);
  }
}