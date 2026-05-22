import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/pos_controller.dart';
import '../widgets/pos_widgets.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Point of Sale',
      child: Container(
        color: posBgColor,
        child: ScreenTypeLayout.builder(
          mobile: (context) => _buildMobileLayout(context),
          desktop: (context) => _buildDesktopLayout(context, isTablet: false),
          tablet: (context) => _buildDesktopLayout(context, isTablet: true),
        ),
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BuildContext context, {required bool isTablet}) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // LEFT: Product Browsing Area (65%)
              Expanded(
                flex: 65,
                child: Padding(
                  padding: const EdgeInsets.all(posPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(),
                      const SizedBox(height: 20),
                      _buildSearchBarRow(),
                      const SizedBox(height: 20),
                      _buildCategoryChips(),
                      const SizedBox(height: 20),
                      Expanded(child: _buildProductGrid(isTablet)),
                    ],
                  ),
                ),
              ),
              // RIGHT: Cart & Checkout Panel (35%)
              Expanded(
                flex: 35,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 30,
                        offset: const Offset(-10, 0),
                      )
                    ],
                  ),
                  child: _buildCartSection(context),
                ),
              ),
            ],
          ),
        ),
        _buildBottomQuickActions(),
      ],
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
            child: TabBar(
              labelColor: AppTheme.primaryColor,
              indicatorColor: AppTheme.primaryColor,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'PRODUCTS', icon: Icon(Icons.grid_view_rounded, size: 20)),
                Tab(text: 'CART', icon: Icon(Icons.shopping_cart_rounded, size: 20)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Products Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSearchBarRow(),
                      const SizedBox(height: 16),
                      _buildCategoryChips(),
                      const SizedBox(height: 16),
                      Expanded(child: _buildProductGrid(false)),
                    ],
                  ),
                ),
                // Cart Tab
                _buildCartSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LEFT PANEL COMPONENTS ---

  Widget _buildTopHeader() {
    return Obx(() => Row(
      children: [
        PosInvoiceTab(
          label: 'New Invoice',
          isSelected: controller.currentInvoiceTab.value == 0,
          onTap: () => controller.currentInvoiceTab.value = 0,
        ),
        PosInvoiceTab(
          label: 'Hold',
          badgeCount: controller.holdCount.value,
          isSelected: controller.currentInvoiceTab.value == 1,
          onTap: () => controller.currentInvoiceTab.value = 1,
        ),
        PosInvoiceTab(
          label: 'Drafts',
          badgeCount: controller.draftCount.value,
          isSelected: controller.currentInvoiceTab.value == 2,
          onTap: () => controller.currentInvoiceTab.value = 2,
        ),
        PosInvoiceTab(
          label: 'Recent',
          isSelected: controller.currentInvoiceTab.value == 3,
          onTap: () => controller.currentInvoiceTab.value = 3,
        ),
      ],
    ));
  }

  Widget _buildSearchBarRow() {
    return Row(
      children: [
        Expanded(
          child: PosSearchBar(
            onChanged: (v) => controller.searchQuery.value = v,
            onBarcodeTap: () {
              // TODO: Implement barcode scan
            },
          ),
        ),
        const SizedBox(width: 12),
        _buildIconAction(Icons.filter_list_rounded, () {}),
      ],
    );
  }

  Widget _buildIconAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 22),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() => SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          CategoryChip(
            label: 'All Items',
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
      final products = controller.filteredProducts;
      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No products found matching your search',
                style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 4,
          childAspectRatio: 0.78,
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

  // --- RIGHT PANEL (CART) COMPONENTS ---

  Widget _buildCartSection(BuildContext context) {
    return Column(
      children: [
        // Invoice Info Header
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderInfo('INVOICE NO', 'INV-${DateFormat('yyyyMMdd').format(DateTime.now())}'),
              _buildHeaderInfo('DATE & TIME', DateFormat('dd MMM, hh:mm a').format(DateTime.now())),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        
        // Customer Selector
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildCustomerSelectorCard(),
        ),

        // Cart List
        Expanded(
          child: Obx(() {
            if (controller.cart.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Text('Your cart is empty', style: GoogleFonts.inter(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.cart.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
              itemBuilder: (context, index) {
                final item = controller.cart[index];
                return CartItemTile(
                  item: item,
                  onUpdateQuantity: (delta) => controller.updateQuantity(item.product.id, delta),
                  onDelete: () => controller.updateQuantity(item.product.id, -item.quantity),
                );
              },
            );
          }),
        ),

        // Billing Summary
        _buildBillingSummary(),
      ],
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildCustomerSelectorCard() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Obx(() => Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.selectedCustomer.value?.name ?? 'Walk-in Customer',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF1E293B)),
                ),
                Text(
                  'Regular Customer',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryColor),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildBillingSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Obx(() => Column(
        children: [
          SummaryRow(label: 'Subtotal', value: '₹${controller.subtotal.toStringAsFixed(2)}'),
          SummaryRow(label: 'Tax (GST)', value: '₹${controller.totalGst.toStringAsFixed(2)}'),
          SummaryRow(label: 'Discount', value: '-₹0.00', isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          SummaryRow(label: 'Total Amount', value: '₹${controller.grandTotal.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 20),
          
          // Payment Methods
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPaymentMethodPill('Cash'),
                _buildPaymentMethodPill('UPI'),
                _buildPaymentMethodPill('Card'),
                _buildPaymentMethodPill('Wallet'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cash Input (if cash selected)
          if (controller.selectedPaymentMethod.value == 'Cash') ...[
            Row(
              children: [
                Expanded(
                  child: _buildSummaryInput('Amount Received', controller.receivedAmount.value.toStringAsFixed(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChangeCard(),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          CheckoutButton(
            amount: controller.grandTotal,
            isLoading: controller.isLoading.value,
            onTap: () => controller.processCheckout(controller.selectedPaymentMethod.value),
          ),
        ],
      )),
    );
  }

  Widget _buildPaymentMethodPill(String method) {
    return Obx(() => PaymentChip(
      label: method,
      isSelected: controller.selectedPaymentMethod.value == method,
      onTap: () => controller.selectedPaymentMethod.value = method,
    ));
  }

  Widget _buildSummaryInput(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text('₹$value', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildChangeCard() {
    double change = controller.receivedAmount.value - controller.grandTotal;
    if (change < 0) change = 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Return Change', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF10B981))),
          const SizedBox(height: 4),
          Text('₹${change.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF065F46))),
        ],
      ),
    );
  }

  Widget _buildBottomQuickActions() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: posPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          QuickActionItem(icon: Icons.pause_circle_outline_rounded, label: 'Hold', shortcut: 'F2', onTap: () {}),
          const SizedBox(width: 8),
          QuickActionItem(icon: Icons.local_offer_outlined, label: 'Discount', shortcut: 'F3', onTap: () {}),
          const SizedBox(width: 8),
          QuickActionItem(icon: Icons.person_search_rounded, label: 'Customer', shortcut: 'F4', onTap: () {}),
          const SizedBox(width: 8),
          QuickActionItem(icon: Icons.edit_calendar_rounded, label: 'Price Chg', shortcut: 'F6', onTap: () {}),
          const SizedBox(width: 8),
          QuickActionItem(icon: Icons.layers_outlined, label: 'Quantity', shortcut: 'F7', onTap: () {}),
          const Spacer(),
          Text(
            'LOGGED IN AS: ADMIN',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
