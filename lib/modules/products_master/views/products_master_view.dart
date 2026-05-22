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

class ProductsMasterView extends GetView<ProductsMasterController> {
  const ProductsMasterView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Products & Master Data',
      child: Container(
        color: const Color(0xFFF5F7FB),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isDesktop = width >= 1400;
            final isTablet = width >= 768 && width < 1400;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderActions(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(isDesktop, isTablet),
                  const SizedBox(height: 32),
                  _buildTabs(),
                  const SizedBox(height: 24),
                  MasterFilterBar(onSearch: (v) => controller.updateSearch(v)),
                  const SizedBox(height: 24),
                  _buildMainContent(isDesktop, isTablet),
                  const SizedBox(height: 32),
                  const MasterInfoBanner(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products & Master Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage your products and related master data in one place',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        Row(
          children: [
            _actionButton(Icons.download_rounded, 'Import'),
            const SizedBox(width: 12),
            _actionButton(Icons.upload_rounded, 'Export'),
            const SizedBox(width: 12),
            _addNewDropdown(),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _addNewDropdown() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'product', child: Text('Add Product')),
        const PopupMenuItem(value: 'category', child: Text('Add Category')),
        const PopupMenuItem(value: 'brand', child: Text('Add Brand')),
        const PopupMenuItem(value: 'unit', child: Text('Add Unit')),
      ],
    );
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
        MasterSummaryCard(title: 'Units', value: controller.unitsCount.value.toString(), icon: Icons.scale_rounded, color: Colors.green, growth: 'Standard'),
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
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Get.theme.primaryColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: isSelected ? 40 : 0,
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

  Widget _buildMainContent(bool isDesktop, bool isTablet) {
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
          return const UnitsTable();
        default:
          return const SizedBox();
      }
    });
  }
}
