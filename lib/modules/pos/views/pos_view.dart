import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/pos_controller.dart';
import '../../../database/database.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Point of Sale',
      child: ScreenTypeLayout.builder(
        mobile: (context) => _buildMobileLayout(),
        tablet: (context) => _buildDesktopLayout(isTablet: true),
        desktop: (context) => _buildDesktopLayout(isTablet: false),
      ),
    );
  }

  Widget _buildDesktopLayout({required bool isTablet}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Section (Left)
        Expanded(
          flex: isTablet ? 3 : 2,
          child: Container(
            color: Get.theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                _buildSearchBar(),
                _buildCategoryTabs(),
                Expanded(child: _buildProductGrid(isTablet: isTablet)),
              ],
            ),
          ),
        ),
        // Cart Section (Right)
        Container(
          width: isTablet ? 320 : 420,
          decoration: BoxDecoration(
            color: Get.theme.cardColor,
            border: Border(left: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              )
            ],
          ),
          child: _buildCartSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Get.theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Products', icon: Icon(Icons.inventory_2)),
              Tab(text: 'Cart', icon: Icon(Icons.shopping_cart)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    _buildSearchBar(),
                    _buildCategoryTabs(),
                    Expanded(child: _buildProductGrid(isTablet: false, isMobile: true)),
                  ],
                ),
                _buildCartSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: 'Search product by name or barcode...',
          prefixIcon: const Icon(Icons.search),
          fillColor: Get.theme.cardColor,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Obx(() => Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', 'All'),
          ...controller.categories.map((c) => _buildCategoryChip(c.name, c.id)),
        ],
      ),
    ));
  }

  Widget _buildCategoryChip(String label, String id) {
    bool isSelected = controller.selectedCategoryId.value == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.selectedCategoryId.value = id,
        selectedColor: Get.theme.primaryColor,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildProductGrid({required bool isTablet, bool isMobile = false}) {
    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    
    return Obx(() {
      final products = controller.filteredProducts;
      if (products.isEmpty) {
        return const Center(child: Text('No products available. Please add items in Inventory.'));
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final bool isOutOfStock = product.stockQuantity <= 0;
          
          return InkWell(
            onTap: isOutOfStock ? null : () => controller.addToCart(product),
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isOutOfStock ? 0.6 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₹${product.price}', style: TextStyle(color: Get.theme.primaryColor, fontWeight: FontWeight.bold)),
                              Text('Stock: ${product.stockQuantity.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          if (isOutOfStock)
                            const Text('OUT OF STOCK', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCartSection() {
    return Column(
      children: [
        // Customer Selection
        _buildCustomerSelector(),
        
        // Cart Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: controller.clearCart, child: const Text('Clear', style: TextStyle(color: Colors.red))),
            ],
          ),
        ),
        
        // Cart Items
        Expanded(
          child: Obx(() {
            if (controller.cart.isEmpty) {
              return const Center(child: Text('No items in cart', style: TextStyle(color: Colors.grey)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.cart.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = controller.cart[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('₹${item.product.price} + ${item.product.gstRate}% GST', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline, size: 18), onPressed: () => controller.updateQuantity(item.product.id, -1)),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_circle_outline, size: 18), onPressed: () => controller.updateQuantity(item.product.id, 1)),
                      ],
                    ),
                    SizedBox(width: 80, child: Text('₹${item.total.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                );
              },
            );
          }),
        ),

        // Summary
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildCustomerSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.primaryColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Customer>(
                    hint: const Text('Select Walk-in Customer'),
                    isExpanded: true,
                    value: controller.selectedCustomer.value,
                    items: controller.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (v) => controller.selectedCustomer.value = v,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.person_add_alt_1_outlined), onPressed: () {
                // TODO: Add quick customer dialog
              })
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Obx(() => Column(
        children: [
          _summaryRow('Subtotal', '₹${controller.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow('GST Total', '₹${controller.totalGst.toStringAsFixed(2)}'),
          const Divider(height: 32),
          _summaryRow('Total Amount', '₹${controller.grandTotal.toStringAsFixed(2)}', isTotal: true),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.cart.isEmpty ? null : () {}, 
                  child: const Text('HOLD'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: controller.cart.isEmpty ? null : () => _showPaymentOptions(),
                  child: const Text('PAY NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? null : Colors.grey.shade600)),
        Text(value, style: TextStyle(fontSize: isTotal ? 24 : 14, fontWeight: FontWeight.bold, color: isTotal ? Get.theme.primaryColor : null)),
      ],
    );
  }

  void _showPaymentOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Get.theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              children: [
                _paymentMethodBox('CASH', Icons.money_outlined, Colors.green),
                const SizedBox(width: 16),
                _paymentMethodBox('CARD', Icons.credit_card_outlined, Colors.blue),
                const SizedBox(width: 16),
                _paymentMethodBox('UPI', Icons.qr_code_2_outlined, Colors.purple),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                child: const Text('CANCEL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodBox(String label, IconData icon, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Get.back();
          controller.processCheckout(label);
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
