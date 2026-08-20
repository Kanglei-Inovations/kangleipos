import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    final theme = Theme.of(context);
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
          color: theme.scaffoldBackgroundColor,
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
                const SizedBox(height: 14),
                Expanded(
                  child: Obx(() {
                    if (controller.currentInvoiceTab.value == 1) {
                      return _buildHoldInvoicesPanel(context);
                    }
                    return Column(
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 12),
                        _buildCategoryChips(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildProductGrid(isTablet: isTablet)),
                        const SizedBox(height: 8),
                        _buildPaginationBar(),
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
                      const SizedBox(height: 12),
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

  // --- MOBILE POS LAYOUT (Matching Screen 6) ---
  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Column(
          children: [
            // Search Bar & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
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
            ),
            const SizedBox(height: 6),

            // Category Chips (Horizontal Scroll)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildCategoryChips(),
            ),
            const SizedBox(height: 8),

            // Product Grid (2-Column)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 70),
                child: _buildProductGrid(isMobile: true),
              ),
            ),
          ],
        ),

        // Sticky Bottom Cart Bar
        Positioned(
          left: 12,
          right: 12,
          bottom: 10,
          child: Obx(() {
            final cartCount = controller.cart.fold<int>(0, (sum, i) => sum + i.quantity.toInt());
            final totalAmount = controller.grandTotal;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF4F46E5), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$cartCount items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '₹ ${NumberFormat('#,##,###.00').format(totalAmount)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _openMobileCartSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('View Cart', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  void _openMobileCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
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
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shopping Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildMobileBillingPanel(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- LEFT PANEL COMPONENTS ---

  Widget _buildTopNav() {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          PosInvoiceTab(
            label: "New Invoice",
            icon: Icons.description_outlined,
            isSelected: controller.currentInvoiceTab.value == 0,
            onTap: () => controller.currentInvoiceTab.value = 0,
          ),
          PosInvoiceTab(
            label: "Hold Invoice",
            icon: Icons.pause_circle_outline,
            badge: controller.holdCount.value > 0 ? controller.holdCount.value.toString() : "3",
            isSelected: controller.currentInvoiceTab.value == 1,
            onTap: () => controller.currentInvoiceTab.value = 1,
          ),
          PosInvoiceTab(
            label: "Drafts",
            icon: Icons.insert_drive_file_outlined,
            badge: controller.draftCount.value > 0 ? controller.draftCount.value.toString() : "6",
            isSelected: controller.currentInvoiceTab.value == 2,
            onTap: () => controller.currentInvoiceTab.value = 2,
          ),
          PosInvoiceTab(
            label: "Recent Invoices",
            icon: Icons.history_rounded,
            isSelected: controller.currentInvoiceTab.value == 3,
            onTap: () => controller.currentInvoiceTab.value = 3,
          ),
        ],
      ),
    ));
  }

  Widget _buildSearchBar() {
    return PosSearchBar(
      onChanged: (v) {
        controller.searchQuery.value = v;
        controller.currentPage.value = 1;
      },
      onBarcodeTap: () {},
      onFilterTap: () {},
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() {
      final defaultCategories = ['All', 'Electronics', 'Mobiles', 'Accessories', 'Fashion', 'Home Appliances', 'Others'];
      final dbCategories = controller.categories.map((c) => c.name).toList();
      final catNames = dbCategories.isNotEmpty ? ['All', ...dbCategories] : defaultCategories;

      return SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: catNames.length,
          itemBuilder: (context, index) {
            final name = catNames[index];
            final isSelected = controller.selectedCategoryId.value == name || 
                (name == 'All' && controller.selectedCategoryId.value == 'All');
            return CategoryChip(
              label: name,
              isSelected: isSelected,
              onTap: () {
                if (name == 'All') {
                  controller.selectedCategoryId.value = 'All';
                } else {
                  final matched = controller.categories.firstWhereOrNull(
                      (c) => c.name.toLowerCase() == name.toLowerCase());
                  controller.selectedCategoryId.value = matched?.id ?? name;
                }
                controller.currentPage.value = 1;
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildProductGrid({bool isMobile = false, bool isTablet = false}) {
    return Obx(() {
      final products = isMobile ? controller.filteredProducts : controller.paginatedProducts;
      final theme = Theme.of(Get.context!);
      final isDark = theme.brightness == Brightness.dark;

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: isDark ? Colors.white24 : Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No products found', 
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
          childAspectRatio: isMobile ? 0.70 : (isTablet ? 0.84 : 0.86),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => PosProductCard(
          product: products[index],
          onTap: () => controller.addToCart(products[index]),
        ),
      );
    });
  }

  Widget _buildPaginationBar() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    return Obx(() {
      final current = controller.currentPage.value;
      final total = math.max(1, controller.totalPages.value);

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _pageNavBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: current > 1 ? () => controller.changePage(current - 1) : null,
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
                for (int i = 1; i <= math.min(5, total); i++) ...[
                  _pageNumberBtn(
                    number: i,
                    isActive: current == i,
                    onTap: () => controller.changePage(i),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 4),
                ],
                if (total > 5) ...[
                  Text('...', style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  _pageNumberBtn(
                    number: total,
                    isActive: current == total,
                    onTap: () => controller.changePage(total),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 4),
                ],
                _pageNavBtn(
                  icon: Icons.chevron_right_rounded,
                  onTap: current < total ? () => controller.changePage(current + 1) : null,
                  isDark: isDark,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Rows per page: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${controller.rowsPerPage.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _pageNumberBtn({required int number, required bool isActive, required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }

  Widget _pageNavBtn({required IconData icon, required VoidCallback? onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? (isDark ? Colors.white70 : const Color(0xFF0F172A)) : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }

  Widget _buildBottomShortcuts() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuickShortcutItem(icon: Icons.pause_circle_outline_rounded, label: "Hold Invoice", shortcut: "F2", color: const Color(0xFF2563EB), bgColor: const Color(0xFFEFF6FF), onTap: () => controller.holdCurrentInvoice()),
          const SizedBox(width: 8),
          QuickShortcutItem(icon: Icons.local_offer_outlined, label: "Discount", shortcut: "F3", color: const Color(0xFF059669), bgColor: const Color(0xFFECFDF5), onTap: () {}),
          const SizedBox(width: 8),
          QuickShortcutItem(icon: Icons.person_outline_rounded, label: "Customer", shortcut: "F4", color: const Color(0xFFDC2626), bgColor: const Color(0xFFFEF2F2), onTap: () => _showSelectCustomerDialog(Get.context!)),
          const SizedBox(width: 8),
          QuickShortcutItem(icon: Icons.edit_note_rounded, label: "Price Change", shortcut: "F5", color: const Color(0xFF16A34A), bgColor: const Color(0xFFF0FDF4), onTap: () {}),
          const SizedBox(width: 8),
          QuickShortcutItem(icon: Icons.format_list_numbered_rounded, label: "Quantity", shortcut: "F6", color: const Color(0xFFD97706), bgColor: const Color(0xFFFFFBEB), onTap: () {}),
          const SizedBox(width: 8),
          QuickShortcutItem(icon: Icons.more_horiz_rounded, label: "More Actions", shortcut: "F7", color: const Color(0xFF4F46E5), bgColor: const Color(0xFFEEF2FF), onTap: () {}),
          const SizedBox(width: 8),
          QuickShortcutItem(icon: Icons.payments_outlined, label: "Pay Checkout", shortcut: "F8", color: const Color(0xFF2563EB), bgColor: const Color(0xFFEFF6FF), onTap: () => controller.processCheckout(controller.selectedPaymentMethod.value)),
        ],
      ),
    );
  }

  // --- HOLD INVOICES PANEL ---
  Widget _buildHoldInvoicesPanel(BuildContext context) {
    final theme = Theme.of(context);
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
                          Icon(Icons.pause_circle_outline, size: 48, color: theme.dividerColor),
                          const SizedBox(height: 12),
                          Text("No invoices on hold", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontWeight: FontWeight.bold)),
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
                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : theme.cardColor,
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
    final theme = Theme.of(Get.context!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hold Invoices", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Manage all your held invoices", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 14)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            controller.currentInvoiceTab.value = 0; // Back to new invoice
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text("New Sale", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      ],
    );
  }

  Widget _buildHoldFilterBar() {
    final theme = Theme.of(Get.context!);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search hold invoice by invoice no, customer...",
              hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.dividerColor)),
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
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.filter_alt_outlined, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _dropdownBox(String hint, IconData icon, {bool isTrailingIcon = false}) {
    final theme = Theme.of(Get.context!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isTrailingIcon) ...[Text(hint, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6))), Icon(icon, size: 18, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6))],
          if (isTrailingIcon) ...[Text(hint, style: TextStyle(color: theme.textTheme.bodyMedium?.color)), Icon(icon, size: 20, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6))],
        ],
      ),
    );
  }

  Widget _buildHoldTableHeader() {
    final theme = Theme.of(Get.context!);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("INVOICE NO", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("CUSTOMER", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("CASHIER", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("HELD ON", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text("QTY", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("TOTAL AMOUNT", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("ACTION", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold))),
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
    final theme = Theme.of(Get.context!);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.receipt_long, color: theme.colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(itemsCount, style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
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
                Text(customerDetail, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(radius: 10, backgroundColor: theme.dividerColor, child: const Icon(Icons.person, size: 14, color: Colors.white)),
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
                Text(time, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
          Expanded(flex: 2, child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _actionBtn(Icons.visibility_outlined, theme.colorScheme.primary, onSee),
                const SizedBox(width: 8),
                _actionBtn(Icons.shopping_cart_outlined, theme.colorScheme.primary, onResume),
                const SizedBox(width: 8),
                _actionBtn(Icons.delete_outline, theme.colorScheme.error, onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(Get.context!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildHoldPagination() {
    final theme = Theme.of(Get.context!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text("Showing ${controller.heldInvoicesList.length} entries", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 12))),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.chevron_left, size: 16)),
              const SizedBox(width: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(4)), child: const Text("1", style: TextStyle(color: Colors.white))),
              const SizedBox(width: 4),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.chevron_right, size: 16)),
              const SizedBox(width: 16),
              Text("Rows per page: ", style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(4)),
                child: Row(children: const [Text("10", style: TextStyle(fontSize: 12)), SizedBox(width: 4), Icon(Icons.arrow_drop_down, size: 16)]),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHoldQuickActions() {
    final theme = Theme.of(Get.context!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyLarge?.color)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _quickActionCard("Resume Selected (F3)", "Resume the selected hold invoice", Icons.play_arrow_outlined, theme.colorScheme.primary, () => controller.resumeHoldInvoice(null))),
            const SizedBox(width: 16),
            Expanded(child: _quickActionCard("Delete Selected (F4)", "Remove the selected hold invoice", Icons.delete_outline, theme.colorScheme.error, () => controller.deleteHoldInvoice(null))),
            const SizedBox(width: 16),
            Expanded(child: _quickActionCard("Clear All Holds (F5)", "Clear all hold invoices", Icons.layers_clear_outlined, Colors.orange, () => controller.clearAllHolds())),
          ],
        )
      ],
    );
  }

  Widget _quickActionCard(String title, String subtitle, IconData icon, Color iconColor, VoidCallback onTap) {
    final theme = Theme.of(Get.context!);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: theme.dividerColor),
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
                  Text(subtitle, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11)),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInvoiceHeader(),
          const SizedBox(height: 12),
          _buildCustomerSelector(),
          const SizedBox(height: 12),
          // Cart Items Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(width: 24, child: Text("#", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text("Item", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.bold))),
                Expanded(child: Text("Price", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.bold))),
                Expanded(child: Center(child: Text("Qty", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.bold)))),
                Expanded(child: Text("Total", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                const SizedBox(width: 32),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 36, color: isDark ? Colors.white24 : Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('Cart is empty', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
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
                icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF2563EB)),
                label: const Text("Add Note", style: TextStyle(color: Color(0xFF2563EB), fontSize: 12.5, fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: () => controller.clearCart(),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                label: const Text("Clear Cart", style: TextStyle(color: Color(0xFFEF4444), fontSize: 12.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildTotals(),
          const SizedBox(height: 12),
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
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Invoice #", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text("INV-10058", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Date", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(DateFormat('MMM dd, yyyy  hh:mm a').format(DateTime.now()), 
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: isDark ? Colors.white70 : const Color(0xFF334155))),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSelector() {
    return Obx(() => CustomerSelector(
      selectedCustomer: controller.selectedCustomer.value,
      onAddCustomer: () => _showAddCustomerDialog(Get.context!),
      onTap: () => _showSelectCustomerDialog(Get.context!),
    ));
  }

  void _showSelectCustomerDialog(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = TextEditingController();
    final rxSearch = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Customer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: searchController,
              onChanged: (v) => rxSearch.value = v.toLowerCase(),
              decoration: InputDecoration(
                hintText: "Search customer by name or phone...",
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Customer List
            Expanded(
              child: Obx(() {
                final query = rxSearch.value;
                final allCustomers = controller.customers;
                final filtered = allCustomers.where((c) {
                  return c.name.toLowerCase().contains(query) ||
                      (c.phone != null && c.phone!.contains(query));
                }).toList();

                return ListView(
                  children: [
                    // Walk-in Customer Option
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.15),
                        child: const Icon(Icons.person_outline, color: Colors.blue),
                      ),
                      title: const Text("Walk-in Customer", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Default / Cash Customer"),
                      trailing: controller.selectedCustomer.value == null
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        controller.selectedCustomer.value = null;
                        Navigator.pop(ctx);
                      },
                    ),
                    const Divider(),

                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text("No customers found.", style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      for (final cust in filtered)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                            child: Text(
                              cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ),
                          title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(cust.phone != null && cust.phone!.isNotEmpty ? cust.phone! : "No phone number"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (cust.balanceDue > 0)
                                Text(
                                  "Due: ₹${cust.balanceDue.toStringAsFixed(0)}",
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                )
                              else
                                const Text("No Due", style: TextStyle(color: Colors.green, fontSize: 11)),
                              if (controller.selectedCustomer.value?.id == cust.id)
                                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            ],
                          ),
                          onTap: () {
                            controller.selectedCustomer.value = cust;
                            Navigator.pop(ctx);
                          },
                        ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),

            // Bottom Create New Customer Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddCustomerDialog(context);
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text("Create New Customer", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    Future<void> pickFromContacts() async {
      try {
        if (await FlutterContacts.requestPermission()) {
          final contact = await FlutterContacts.openExternalPick();
          if (contact != null) {
            nameController.text = contact.displayName;
            if (contact.phones.isNotEmpty) {
              phoneController.text = contact.phones.first.number;
            }
          }
        } else {
          Get.snackbar("Permission Denied", "Contact permission is required to select from phone contacts.",
              backgroundColor: Colors.orange, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar("Contacts Unavailable", "Could not access phone contacts: $e",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_add_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            const Text("Add New Customer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Contact Picker Button
              OutlinedButton.icon(
                onPressed: pickFromContacts,
                icon: const Icon(Icons.contacts_rounded, color: Colors.blue),
                label: const Text("Import from Phone Contacts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Customer Name *",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Address (Optional)",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar("Required Field", "Please enter customer name",
                    backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }

              final newCust = await controller.addNewCustomer(
                name: name,
                phone: phoneController.text.trim(),
                address: addressController.text.trim(),
              );

              Navigator.pop(ctx);
              Get.snackbar("Success", "Customer ${newCust.name} created & selected!",
                  backgroundColor: Colors.green, colorText: Colors.white);
            },
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            label: const Text("Save & Select", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    final theme = Theme.of(Get.context!);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final subtotal = controller.subtotal;
      final discount = controller.discount;
      final taxable = subtotal - discount;
      final cgst = controller.cgst;
      final sgst = controller.sgst;
      final grandTotal = controller.grandTotal;

      return Column(
        children: [
          BillSummaryRow(label: "Subtotal", value: "₹ ${NumberFormat('#,##,###.00').format(subtotal)}"),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Discount",
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? const Color(0xFF059669).withValues(alpha: 0.3) : const Color(0xFFDCFCE7),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text("FLAT10", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          SizedBox(width: 2),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  "- ₹ ${NumberFormat('#,##,###.00').format(discount)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          BillSummaryRow(label: "Taxable Amount", value: "₹ ${NumberFormat('#,##,###.00').format(taxable)}"),
          BillSummaryRow(label: "CGST (9%)", value: "₹ ${NumberFormat('#,##,###.00').format(cgst)}"),
          BillSummaryRow(label: "SGST (9%)", value: "₹ ${NumberFormat('#,##,###.00').format(sgst)}"),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹ ${NumberFormat('#,##,###.00').format(grandTotal)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    "You Saved ₹ ${NumberFormat('#,##,###.00').format(discount)}",
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      );
    });
  }



  Widget _buildMobileBillingPanel(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer & Invoice Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                _buildInvoiceHeader(),
                const SizedBox(height: 10),
                _buildCustomerSelector(),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cart Items Section
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            padding: const EdgeInsets.all(12),
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 36, color: theme.dividerColor),
                        const SizedBox(height: 8),
                        Text('Cart is empty', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Switch to PRODUCTS tab to add items', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4), fontSize: 11)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cart Items (${controller.cart.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextButton.icon(
                        onPressed: () => controller.clearCart(),
                        icon: Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.error),
                        label: Text("Clear", style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                      ),
                    ],
                  ),
                  const Divider(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.cart.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = controller.cart[index];
                      return CartItemTile(
                        index: index + 1,
                        item: item,
                        onUpdateQuantity: (delta) => controller.updateQuantity(item.product.id, delta),
                        onDelete: () => controller.updateQuantity(item.product.id, -item.quantity),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),

          // Summary & Checkout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                _buildTotals(),
                const SizedBox(height: 16),
                Obx(() => CheckoutAction(
                  amount: controller.grandTotal,
                  receivedAmount: controller.receivedAmount.value,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.processCheckout(controller.selectedPaymentMethod.value),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
