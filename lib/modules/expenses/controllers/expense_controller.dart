import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/preference_service.dart';

class ExpenseController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<Expense> expenses = <Expense>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  final List<String> categories = ['Utility', 'Salary', 'Rent', 'Petty Cash', 'Marketing', 'Others'];

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final list = await db.select(db.expenses).get();
      expenses.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  // KPIs
  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);
  
  double get totalThisMonth {
    final now = DateTime.now();
    return expenses.where((e) => e.expenseDate.month == now.month && e.expenseDate.year == now.year).fold(0.0, (sum, e) => sum + e.amount);
  }
  
  double get totalThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return expenses.where((e) => e.expenseDate.isAfter(startOfWeek)).fold(0.0, (sum, e) => sum + e.amount);
  }
  
  double get totalToday {
    final now = DateTime.now();
    return expenses.where((e) => e.expenseDate.day == now.day && e.expenseDate.month == now.month && e.expenseDate.year == now.year).fold(0.0, (sum, e) => sum + e.amount);
  }

  int get pendingApprovals => 5; // Mocked

  // Category Summaries
  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (var e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  List<Expense> get filteredExpenses {
    return expenses.where((e) {
      final q = searchQuery.value.toLowerCase();
      return e.description.toLowerCase().contains(q) || 
             e.category.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> addExpense({
    required String category,
    required String description,
    required double amount,
  }) async {
    final id = _uuid.v4();
    await db.into(db.expenses).insert(ExpensesCompanion(
      id: d.Value(id),
      category: d.Value(category),
      description: d.Value(description),
      amount: d.Value(amount),
      loggedBy: d.Value(Get.find<PreferenceService>().authUserId ?? 'unknown'),
      expenseDate: d.Value(DateTime.now()),
    ));
    await refreshData();
  }

  Future<void> deleteExpense(String id) async {
    await (db.delete(db.expenses)..where((t) => t.id.equals(id))).go();
    await refreshData();
  }
}
