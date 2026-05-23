import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/layout/main_layout.dart';
import '../controllers/add_product_controller.dart';
import '../widgets/add_product_widgets.dart';

class AddProductPage extends GetView<AddProductController> {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MainLayout(
      title: 'Add New Product',
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isDesktop = width >= 1100;
                    
                    if (isDesktop) {
                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _LeftColumn()),
                          SizedBox(width: 24),
                          Expanded(flex: 2, child: _RightColumn()),
                        ],
                      );
                    } else {
                      return const Column(
                        children: [
                          _LeftColumn(),
                          SizedBox(height: 24),
                          _RightColumn(),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: theme.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Inventory', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13)),
                  Icon(Icons.chevron_right, size: 16, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
                  Text('Products', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Add New Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
            ],
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.saveProduct(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: controller.isLoading.value 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ProductBasicInfoCard(),
        SizedBox(height: 24),
        ProductImageUploadCard(),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ProductPricingCard(),
        SizedBox(height: 24),
        ProductInventoryCard(),
        SizedBox(height: 24),
        ProductAdditionalInfoCard(),
      ],
    );
  }
}
