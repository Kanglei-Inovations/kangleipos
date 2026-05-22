import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/products_master_controller.dart';
import '../widgets/master_summary_card.dart';
import '../widgets/master_filter_bar.dart';
import '../widgets/products_table.dart';
import '../widgets/categories_table.dart';
import '../widgets/brands_table.dart';
import '../widgets/units_table.dart';
import '../widgets/master_info_banner.dart';
import '../widgets/master_dialogs.dart';

class ProductsMasterPage extends GetView<ProductsMasterController> {
  const ProductsMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Products & Master Data',
      child: Container(
        color: const Color(0xFFF5F7FB),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isDesktop = width >= 1200;
            final isTablet = width >= 768 && width < 1200;

            return Column(
              children: [
                _buildHeaderActions(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(isDesktop, isTablet),
                        const SizedBox(height: 16),
                        MasterFilterBar(onSearch: controller.updateSearch),
                        const SizedBox(height: 24),
                        _buildTabs(),
                        _buildMainContent(),
                        const SizedBox(height: 32),
                        const MasterInfoBanner(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products & Master Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Text(
                'Manage your products and related master data in one place',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              _actionButton(Icons.download_rounded, 'Import', () => _showImportDialog()),
              const SizedBox(width: 8),
              _actionButton(Icons.upload_rounded, 'Export', () => _handleExport()),
              const SizedBox(width: 12),
              _addNewButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: const Color(0xFF475569)),
      label: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _addNewButton() {
    return ElevatedButton.icon(
      onPressed: () => Get.dialog(const MasterAddNewModal(), barrierDismissible: true),
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
      label: const Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Get.theme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  void _showImportDialog() {
    Get.defaultDialog(
      title: 'Import Data',
      content: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Upload your CSV or Excel file to bulk import products.'),
      ),
      textConfirm: 'SELECT FILE',
      onConfirm: () => Get.back(),
    );
  }

  void _handleExport() {
    Get.snackbar('Exporting', 'Generating PDF and Excel reports...', backgroundColor: Colors.blue, colorText: Colors.white);
  }

  Widget _buildSummaryCards(bool isDesktop, bool isTablet) {
    int count = isDesktop ? 4 : (isTablet ? 2 : 1);
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.8,
      children: [
        MasterSummaryCard(title: 'Total Products', value: controller.totalProductsCount.value.toString(), icon: Icons.shopping_bag_rounded, color: Colors.blue, growth: '+12%'),
        MasterSummaryCard(title: 'Categories', value: controller.categoriesCount.value.toString(), icon: Icons.category_rounded, color: Colors.purple, growth: '+2'),
        MasterSummaryCard(title: 'Brands', value: controller.brandsCount.value.toString(), icon: Icons.branding_watermark_rounded, color: Colors.orange, growth: '+5'),
        MasterSummaryCard(title: 'Units', value: controller.unitsCount.value.toString(), icon: Icons.scale_rounded, color: Colors.green, growth: 'Active'),
      ],
    ));
  }

  Widget _buildTabs() {
    final List<String> tabs = ['Products', 'Categories', 'Brands', 'Units'];
    return Obx(() => Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = controller.selectedTabIndex.value == index;
        return Padding(
          padding: const EdgeInsets.only(right: 32),
          child: InkWell(
            onTap: () => controller.selectedTabIndex.value = index,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Get.theme.primaryColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  width: isSelected ? 30 : 0,
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
      }

      switch (controller.selectedTabIndex.value) {
        case 0:
          return ProductsTable(products: controller.filteredProducts);
        case 1:
          return CategoriesTable(categories: controller.filteredCategories);
        case 2:
          return BrandsTable(brands: controller.filteredBrands);
        case 3:
          return UnitsTable(units: controller.dummyUnits);
        default:
          return const SizedBox();
      }
    });
  }
}
