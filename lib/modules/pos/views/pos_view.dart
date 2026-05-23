import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:responsive_builder/responsive_builder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/pos_controller.dart';
import '../widgets/pos_widgets.dart';
import '../../../database/database.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Billing Terminal',
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // F2: Hold Current Invoice
            if (event.logicalKey == LogicalKeyboardKey.f2) {
              controller.holdCurrentInvoice();
              return KeyEventResult.handled;
            }
            // F3: Resume Selected Hold
            if (event.logicalKey == LogicalKeyboardKey.f3) {
              if (controller.currentInvoiceTab.value == 1 && controller.selectedHeldInvoice.value != null) {
                controller.resumeHoldInvoice(null);
              }
              return KeyEventResult.handled;
            }
            // F4: Delete Selected Hold
            if (event.logicalKey == LogicalKeyboardKey.f4) {
              if (controller.currentInvoiceTab.value == 1 && controller.selectedHeldInvoice.value != null) {
                controller.deleteHoldInvoice(null);
              }
              return KeyEventResult.handled;
            }
            // F5: Clear All Holds (only when in Hold Tab)
            if (event.logicalKey == LogicalKeyboardKey.f5) {
              if (controller.currentInvoiceTab.value == 1) {
                controller.clearAllHolds();
              }
              return KeyEventResult.handled;
            }
            // F8: Checkout
            if (event.logicalKey == LogicalKeyboardKey.f8) {
              if (controller.cart.isNotEmpty) {
                controller.processCheckout(controller.selectedPaymentMethod.value);
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          color: posBgColor,
          child: ScreenTypeLayout.builder(
            mobile: (context) => _buildMobileLayout(context),
            desktop: (context) => _buildDesktopLayout(context, isTablet: false),
            tablet: (context) => _buildDesktopLayout(context, isTablet: true),
          ),
        ),
      ),
    );
  }

  // --- DESKTOP LAYOUT (MATCHING REFERENCE SNIPPET) ---
  Widget _buildDesktopLayout(BuildContext context, {required bool isTablet}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel (Product Catalog or Hold Panel) - flex: 6
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildTopNav(),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.currentInvoiceTab.value == 1) {
                      return _buildHoldInvoicesPanel(context);
                    }
                    return Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildCategoryChips(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildProductGrid(isTablet)),
                      ],
                    );
                  }),
                ),
                Obx(() {
                  if (controller.currentInvoiceTab.value == 1) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildBottomShortcuts(),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Panel (Cart & Checkout) - flex: 4
          Expanded(
            flex: 4,
            child: _buildRightPanel(context),
          ),
        ],
      ),
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'PRODUCTS', icon: Icon(Icons.grid_view_rounded, size: 20)),
                Tab(text: 'BILLING', icon: Icon(Icons.receipt_long_rounded, size: 20)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildCategoryChips(),
                      const SizedBox(height: 12),
                      Expanded(child: _buildProductGrid(false)),
                    ],
                  ),
                ),
                _buildRightPanel(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LEFT PANEL COMPONENTS ---

  Widget _buildTopNav() {
    return Obx(() => Row(
      children: [
        _navTab("New Invoice", Icons.description_outlined, 
          isActive: controller.currentInvoiceTab.value == 0,
          onTap: () => controller.currentInvoiceTab.value = 0),
        _navTab("Hold Invoice", Icons.pause_circle_outline, 
          isActive: controller.currentInvoiceTab.value == 1,
          badge: controller.holdCount.value.toString(),
          onTap: () => controller.currentInvoiceTab.value = 1),
        _navTab("Drafts", Icons.drafts_outlined, 
          isActive: controller.currentInvoiceTab.value == 2,
          badge: controller.draftCount.value.toString(),
          onTap: () => controller.currentInvoiceTab.value = 2),
        _navTab("Recent Invoices", Icons.history, 
          isActive: controller.currentInvoiceTab.value == 3,
          onTap: () => controller.currentInvoiceTab.value = 3),
      ],
    ));
  }

  Widget _navTab(String title, IconData icon, {bool isActive = false, String? badge, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          border: isActive ? Border.all(color: Colors.blue.shade200) : Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey.shade600, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.blueAccent : Colors.grey.shade800,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (badge != null && badge != "0") ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return PosSearchBar(
      onChanged: (v) => controller.searchQuery.value = v,
      onBarcodeTap: () {},
      onFilterTap: () {},
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() => SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryChip(
            label: "All",
            isSelected: controller.selectedCategoryId.value == 'All',
            onTap: () => controller.selectedCategoryId.value = 'All',
          ),
          ...controller.categories.map((cat) => CategoryChip(
            label: cat.name,
            isSelected: controller.selectedCategoryId.value == cat.id,
            onTap: () => controller.selectedCategoryId.value = cat.id,
          )),
        ],
      ),
    ));
  }

  Widget _buildProductGrid(bool isTablet) {
    return Obx(() {
      final products = controller.paginatedProducts;
      if (products.isEmpty) {
        return Center(
          child: Text('No products found', 
            style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
        );
      }
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => PosProductCard(
          product: products[index],
          onTap: () => controller.addToCart(products[index]),
        ),
      );
    });
  }

  Widget _buildBottomShortcuts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        QuickShortcutItem(icon: Icons.save_outlined, label: "Hold Invoice", shortcut: "F2", onTap: () => controller.holdCurrentInvoice()),
        QuickShortcutItem(icon: Icons.local_offer_outlined, label: "Discount", shortcut: "F3", onTap: () {}),
        QuickShortcutItem(icon: Icons.person_outline, label: "Customer", shortcut: "F4", onTap: () {}),
        QuickShortcutItem(icon: Icons.edit_note, label: "Price Change", shortcut: "F5", onTap: () {}),
        QuickShortcutItem(icon: Icons.format_list_numbered, label: "Quantity", shortcut: "F6", onTap: () {}),
        QuickShortcutItem(icon: Icons.more_horiz, label: "More Actions", shortcut: "F7", onTap: () {}),
        QuickShortcutItem(icon: Icons.payment, label: "Pay Checkout", shortcut: "F8", onTap: () => controller.processCheckout(controller.selectedPaymentMethod.value)),
      ],
    );
  }

  // --- HOLD INVOICES PANEL ---
  Widget _buildHoldInvoicesPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHoldHeaderRow(),
        const SizedBox(height: 16),
        _buildHoldFilterBar(),
        const SizedBox(height: 24),
        Expanded(
          child: Column(
            children: [
              _buildHoldTableHeader(),
              Expanded(
                child: Obx(() {
                  if (controller.heldInvoicesList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pause_circle_outline, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          const Text("No invoices on hold", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.heldInvoicesList.length,
                    itemBuilder: (context, index) {
                      final inv = controller.heldInvoicesList[index];
                      final isSelected = controller.selectedHeldInvoice.value?.id == inv.id;
                      final customer = controller.customers.firstWhereOrNull((c) => c.id == inv.customerId);
                      final items = controller.heldItemsMap[inv.id] ?? [];
                      final totalQty = items.fold(0.0, (sum, item) => sum + item.quantity).toInt();
                      
                      return Material(
                        color: isSelected ? Colors.blue.withOpacity(0.08) : Colors.white,
                        child: InkWell(
                          onTap: () => controller.selectedHeldInvoice.value = inv,
                          child: _buildHoldInvoiceListItem(
                            isSelected: isSelected,
                            invoiceNo: inv.invoiceNumber,
                            itemsCount: "${items.length} Items",
                            customerName: customer?.name ?? "Walk-in Customer",
                            customerDetail: customer?.phone ?? "Default",
                            cashierName: "Admin User",
                            date: DateFormat('MMM dd, yyyy').format(inv.createdAt),
                            time: DateFormat('hh:mm a').format(inv.createdAt),
                            qty: "$totalQty",
                            amount: "₹ ${NumberFormat('#,##,###.00').format(inv.grandTotal)}",
                            onSee: () => _showInvoiceDetailsDialog(context, inv, items),
                            onResume: () => controller.resumeHoldInvoice(inv),
                            onDelete: () => controller.deleteHoldInvoice(inv),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              _buildHoldPagination(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildHoldQuickActions(),
      ],
    );
  }

  void _showInvoiceDetailsDialog(BuildContext context, Invoice inv, List<InvoiceItem> items) {
    Get.dialog(
      AlertDialog(
        title: Text("Invoice Details: ${inv.invoiceNumber}"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var item in items)
                ListTile(
                  title: Text(item.productName),
                  subtitle: Text("Price: ₹${item.unitPrice}"),
                  trailing: Text("Qty: ${item.quantity.toInt()}"),
                ),
              const Divider(),
              ListTile(
                title: const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text("₹${NumberFormat('#,##,###.00').format(inv.grandTotal)}", style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Close")),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.resumeHoldInvoice(inv);
            }, 
            child: const Text("Resume Invoice"),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Hold Invoices", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Manage all your held invoices", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            controller.currentInvoiceTab.value = 0; // Back to new invoice
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text("New Sale", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      ],
    );
  }

  Widget _buildHoldFilterBar() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search hold invoice by invoice no, customer...",
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _dropdownBox("Date Range", Icons.calendar_today_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _dropdownBox("All Cashiers", Icons.keyboard_arrow_down, isTrailingIcon: true)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.filter_alt_outlined, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _dropdownBox(String hint, IconData icon, {bool isTrailingIcon = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isTrailingIcon) ...[Text(hint, style: TextStyle(color: Colors.grey.shade600)), Icon(icon, size: 18, color: Colors.grey.shade600)],
          if (isTrailingIcon) ...[Text(hint, style: TextStyle(color: Colors.grey.shade800)), Icon(icon, size: 20, color: Colors.grey.shade600)],
        ],
      ),
    );
  }

  Widget _buildHoldTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text("INVOICE NO", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("CUSTOMER", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("CASHIER", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("HELD ON", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("QTY", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("TOTAL AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("ACTION", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildHoldInvoiceListItem({
    required bool isSelected,
    required String invoiceNo, required String itemsCount, required String customerName,
    required String customerDetail, required String cashierName, required String date,
    required String time, required String qty, required String amount,
    required VoidCallback onSee, required VoidCallback onResume, required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.receipt_long, color: Colors.blueAccent.shade400, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(itemsCount, style: TextStyle(color: Colors.blueAccent.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(customerDetail, style: TextStyle(color: Colors.grey.shade500, fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const CircleAvatar(radius: 10, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 14, color: Colors.white)),
                const SizedBox(width: 8),
                Expanded(child: Text(cashierName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
          Expanded(flex: 2, child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionBtn(Icons.visibility_outlined, Colors.blueAccent, onSee),
                const SizedBox(width: 8),
                _actionBtn(Icons.shopping_cart_outlined, Colors.blueAccent, onResume),
                const SizedBox(width: 8),
                _actionBtn(Icons.delete_outline, Colors.redAccent, onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildHoldPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text("Showing ${controller.heldInvoicesList.length} entries", style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.chevron_left, size: 16)),
              const SizedBox(width: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)), child: const Text("1", style: TextStyle(color: Colors.white))),
              const SizedBox(width: 4),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.chevron_right, size: 16)),
              const SizedBox(width: 16),
              const Text("Rows per page: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                child: Row(children: const [Text("10", style: TextStyle(fontSize: 12)), SizedBox(width: 4), Icon(Icons.arrow_drop_down, size: 16)]),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHoldQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _quickActionCard("Resume Selected (F3)", "Resume the selected hold invoice", Icons.play_arrow_outlined, Colors.blue, () => controller.resumeHoldInvoice(null))),
            const SizedBox(width: 16),
            Expanded(child: _quickActionCard("Delete Selected (F4)", "Remove the selected hold invoice", Icons.delete_outline, Colors.red, () => controller.deleteHoldInvoice(null))),
            const SizedBox(width: 16),
            Expanded(child: _quickActionCard("Clear All Holds (F5)", "Clear all hold invoices", Icons.layers_clear_outlined, Colors.orange, () => controller.clearAllHolds())),
          ],
        )
      ],
    );
  }

  Widget _quickActionCard(String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 13)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- RIGHT PANEL COMPONENTS ---

  Widget _buildRightPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInvoiceHeader(),
          const Divider(height: 32),
          _buildCustomerSelector(),
          const SizedBox(height: 16),
          // Cart Items Header
          Row(
            children: const [
              SizedBox(width: 30, child: Text("#", style: TextStyle(color: Colors.grey, fontSize: 12))),
              Expanded(flex: 3, child: Text("Item", style: TextStyle(color: Colors.grey, fontSize: 12))),
              Expanded(child: Text("Price", style: TextStyle(color: Colors.grey, fontSize: 12))),
              Expanded(child: Text("Qty", style: TextStyle(color: Colors.grey, fontSize: 12))),
              Expanded(child: Text("Total", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.right)),
              SizedBox(width: 35),
            ],
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return Center(
                  child: Text('Cart is empty', style: TextStyle(color: Colors.grey.shade400)),
                );
              }
              return ListView.builder(
                itemCount: controller.cart.length,
                itemBuilder: (context, index) {
                  final item = controller.cart[index];
                  return CartItemTile(
                    index: index + 1,
                    item: item,
                    onUpdateQuantity: (delta) => controller.updateQuantity(item.product.id, delta),
                    onDelete: () => controller.updateQuantity(item.product.id, -item.quantity),
                  );
                },
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Add Note"),
              ),
              TextButton.icon(
                onPressed: () => controller.clearCart(),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("Clear Cart", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildTotals(),
          const SizedBox(height: 24),
          _buildPaymentMethods(),
          const SizedBox(height: 16),
          Obx(() => CheckoutAction(
            amount: controller.grandTotal,
            receivedAmount: controller.receivedAmount.value,
            isLoading: controller.isLoading.value,
            onTap: () => controller.processCheckout(controller.selectedPaymentMethod.value),
          )),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Invoice #", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text("INV-10058", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text("Date", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now()), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSelector() {
    return Obx(() => CustomerSelector(
      selectedCustomer: controller.selectedCustomer.value,
      onAddCustomer: () {},
      onTap: () {},
    ));
  }

  Widget _buildTotals() {
    return Obx(() => Column(
      children: [
        BillSummaryRow(label: "Subtotal", value: "₹ ${NumberFormat('#,##,###.00').format(controller.subtotal)}"),
        BillSummaryRow(label: "Discount (FLAT10)", value: "- ₹ 0.00", isDiscount: true),
        BillSummaryRow(label: "Taxable Amount", value: "₹ ${NumberFormat('#,##,###.00').format(controller.subtotal)}"),
        BillSummaryRow(label: "CGST (9%)", value: "₹ ${(controller.totalGst / 2).toStringAsFixed(2)}"),
        BillSummaryRow(label: "SGST (9%)", value: "₹ ${(controller.totalGst / 2).toStringAsFixed(2)}"),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹ ${NumberFormat('#,##,###.00').format(controller.grandTotal)}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF1E293B))),
                const Text("You Saved ₹ 0.00", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        )
      ],
    ));
  }

  Widget _buildPaymentMethods() {
    final methods = ["Cash", "UPI", "Card", "Net Banking", "Wallet", "Split"];
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: methods.map((m) => Expanded(
        child: InkWell(
          onTap: () => controller.selectedPaymentMethod.value = m,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: controller.selectedPaymentMethod.value == m ? Colors.blue : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: controller.selectedPaymentMethod.value == m ? Colors.blue.withOpacity(0.05) : Colors.white,
            ),
            child: Center(
              child: Text(m, style: TextStyle(
                color: controller.selectedPaymentMethod.value == m ? Colors.blue : Colors.black87,
                fontSize: 12,
                fontWeight: controller.selectedPaymentMethod.value == m ? FontWeight.bold : FontWeight.normal
              )),
            ),
          ),
        ),
      )).toList(),
    ));
  }
}
