import 'package:get/get.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/pos/views/pos_view.dart';
import '../../modules/pos/bindings/pos_binding.dart';
import '../../modules/sales/views/sales_view.dart';
import '../../modules/sales/bindings/sales_binding.dart';
import '../../modules/inventory/views/inventory_view.dart';
import '../../modules/inventory/bindings/inventory_binding.dart';
import '../../modules/products_master/views/products_master_view.dart';
import '../../modules/products_master/bindings/products_master_binding.dart';
import '../../modules/customers/views/customer_view.dart';
import '../../modules/customers/bindings/customer_binding.dart';
import '../../modules/suppliers/views/supplier_view.dart';
import '../../modules/suppliers/bindings/supplier_binding.dart';
import '../../modules/purchases/views/purchase_view.dart';
import '../../modules/purchases/bindings/purchase_binding.dart';
import '../../modules/expenses/views/expense_view.dart';
import '../../modules/expenses/bindings/expense_binding.dart';
import '../../modules/reports/views/reports_view.dart';
import '../../modules/reports/bindings/reports_binding.dart';
import '../../modules/gst/views/gst_view.dart';
import '../../modules/gst/bindings/gst_binding.dart';
import '../../modules/users/views/user_view.dart';
import '../../modules/users/bindings/user_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/backup/views/backup_view.dart';
import '../../modules/backup/bindings/backup_binding.dart';
import '../../modules/sync/views/sync_view.dart';
import '../../modules/sync/bindings/sync_binding.dart';
import '../../modules/auth/views/setup_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.AUTH,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SETUP,
      page: () => SetupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.POS,
      page: () => const PosView(),
      binding: PosBinding(),
    ),
    GetPage(
      name: AppRoutes.SALES,
      page: () => const SalesView(),
      binding: SalesBinding(),
    ),
    GetPage(
      name: AppRoutes.INVENTORY,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCTS_MASTER,
      page: () => const ProductsMasterView(),
      binding: ProductsMasterBinding(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMERS,
      page: () => const CustomerView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: AppRoutes.SUPPLIERS,
      page: () => const SupplierView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: AppRoutes.PURCHASES,
      page: () => const PurchaseView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: AppRoutes.EXPENSES,
      page: () => const ExpenseView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: AppRoutes.GST,
      page: () => const GstView(),
      binding: GstBinding(),
    ),
    GetPage(
      name: AppRoutes.USERS,
      page: () => const UserView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.BACKUP,
      page: () => const BackupView(),
      binding: BackupBinding(),
    ),
    GetPage(
      name: AppRoutes.SYNC,
      page: () => const SyncView(),
      binding: SyncBinding(),
    ),
    // Add other routes here
  ];
}
