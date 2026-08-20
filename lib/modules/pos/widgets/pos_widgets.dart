import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../database/database.dart';
import '../controllers/pos_controller.dart';
import '../models/cart_item.dart';

// --- PRODUCT CARD (MATCHING REFERENCE 2_POS.png) ---
class PosProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const PosProductCard({super.key, required this.product, required this.onTap});

  @override
  State<PosProductCard> createState() => _PosProductCardState();
}

class _PosProductCardState extends State<PosProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isOutOfStock = (widget.product.stockQuantity) <= 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: isOutOfStock ? null : widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF2563EB)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.02),
                blurRadius: _isHovered ? 10 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: Center(
                  child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_outlined, size: 28, color: isDark ? Colors.white24 : Colors.grey[300]),
                          ),
                        )
                      : Icon(Icons.inventory_2_outlined, size: 28, color: isDark ? Colors.white24 : Colors.grey[300]),
                ),
              ),
              const SizedBox(height: 4),
              // Product Name
              Text(
                widget.product.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Product Variant / Spec
              Text(
                widget.product.description ?? "Standard Variant",
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                "₹ ${NumberFormat('#,##,###.00').format(widget.product.price)}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              // Stock Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isOutOfStock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            isOutOfStock ? "Out of Stock" : "In Stock",
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isOutOfStock ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.product.stockQuantity.toInt()}",
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CART ITEM ROW (CLEAN, COMPACT, NO THUMBNAIL ICON) ---
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(int) onUpdateQuantity;
  final VoidCallback onDelete;
  final int index;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              "$index",
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "₹ ${NumberFormat('#,##,###.00').format(item.product.price)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => onUpdateQuantity(-1),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.remove, size: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    "${item.quantity}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => onUpdateQuantity(1),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.add, size: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Total
          SizedBox(
            width: 72,
            child: Text(
              "₹ ${NumberFormat('#,##,###.00').format(item.total)}",
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- BILL SUMMARY ROW (MATCHING REFERENCE 2_POS.png) ---
class BillSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isDiscount;
  final bool isTax;

  const BillSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isDiscount = false,
    this.isTax = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12.5,
              color: isDiscount ? const Color(0xFF10B981) : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOMER SELECTOR (MATCHING REFERENCE 2_POS.png) ---
class CustomerSelector extends StatelessWidget {
  final Customer? selectedCustomer;
  final VoidCallback onAddCustomer;
  final VoidCallback onTap;

  const CustomerSelector({
    super.key,
    this.selectedCustomer,
    required this.onAddCustomer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: Color(0xFF2563EB), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCustomer?.name ?? 'Walk-in Customer',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          selectedCustomer?.phone ?? 'Default',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onAddCustomer,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_rounded, size: 22, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}

// --- SEARCH BAR (MATCHING REFERENCE 2_POS.png) ---
class PosSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onBarcodeTap;
  final VoidCallback onFilterTap;

  const PosSearchBar({
    super.key, 
    required this.onChanged, 
    required this.onBarcodeTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
            ),
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Scan barcode or search product...",
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                suffixIcon: InkWell(
                  onTap: onBarcodeTap,
                  child: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Color(0xFF94A3B8)),
                ),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                "All Categories",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}

// --- INVOICE TAB (MATCHING REFERENCE 2_POS.png) ---
class PosInvoiceTab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const PosInvoiceTab({
    super.key,
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
    this.icon = Icons.description_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFFEFF6FF))
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (badge != null && badge != "0") ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- CHECKOUT AREA (MATCHING REFERENCE 2_POS.png) ---
class CheckoutAction extends StatefulWidget {
  final double amount;
  final VoidCallback onTap;
  final bool isLoading;
  final double receivedAmount;

  const CheckoutAction({
    super.key,
    required this.amount,
    required this.onTap,
    this.isLoading = false,
    required this.receivedAmount,
  });

  @override
  State<CheckoutAction> createState() => _CheckoutActionState();
}

class _CheckoutActionState extends State<CheckoutAction> {
  late TextEditingController _receivedCtrl;

  final Map<String, TextEditingController> _splitCtrls = {
    'Cash': TextEditingController(),
    'UPI': TextEditingController(),
    'Card': TextEditingController(),
    'Net Banking': TextEditingController(),
    'Wallet': TextEditingController(),
  };

  static const _methods = ['Cash', 'UPI', 'Card', 'Net Banking', 'Wallet', 'Split'];

  @override
  void initState() {
    super.initState();
    _receivedCtrl = TextEditingController(
      text: widget.receivedAmount == 0 ? '' : widget.receivedAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _receivedCtrl.dispose();
    for (final c in _splitCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pos = Get.find<PosController>();
    final total = widget.amount;

    return Obx(() {
      final method = pos.selectedPaymentMethod.value;
      final isSplit = method == 'Split';
      final isDue = method == 'Due';

      double received = pos.receivedAmount.value;
      if (isSplit) {
        received = pos.splitAmounts.values.fold(0.0, (a, b) => a + b);
      }

      final change = math.max(0.0, received - total);
      final due = math.max(0.0, total - received);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Payment Method Selector Tabs ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _methods.map((m) {
                final sel = method == m;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => pos.selectedPaymentMethod.value = m,
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? (isDark ? const Color(0xFF2563EB).withValues(alpha: 0.2) : const Color(0xFFEFF6FF))
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        border: Border.all(
                          color: sel
                              ? const Color(0xFF2563EB)
                              : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                          color: sel
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Received Amount & Change to Return Row ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Received Amount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: _receivedCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => pos.receivedAmount.value = double.tryParse(v) ?? 0.0,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixText: '₹ ',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF059669).withValues(alpha: 0.3) : const Color(0xFFDCFCE7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Change to Return',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹ ${NumberFormat('#,##,###.00').format(change)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Big Pay / Checkout Button ──
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDue
                    ? Colors.orange
                    : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isDue
                              ? Icons.account_balance_wallet_outlined
                              : received >= total && total > 0
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isDue
                                ? 'Record as DUE (₹${total.toStringAsFixed(0)})'
                                : isSplit
                                    ? 'Complete Split Sale'
                                    : received >= total && total > 0
                                        ? 'Pay / Checkout (F8) →'
                                        : received > 0
                                            ? 'Partial Sale (Due ₹${due.toStringAsFixed(0)})'
                                            : 'Pay / Checkout (F8) →',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
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

// --- QUICK SHORTCUT ITEM (MATCHING REFERENCE 2_POS.png) ---
class QuickShortcutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String shortcut;
  final VoidCallback onTap;
  final Color? color;
  final Color? bgColor;

  const QuickShortcutItem({
    super.key,
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.onTap,
    this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemColor = color ?? const Color(0xFF2563EB);
    final itemBgColor = bgColor ?? (isDark ? itemColor.withValues(alpha: 0.15) : itemColor.withValues(alpha: 0.08));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: itemBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: itemColor),
            ),
            const SizedBox(width: 7),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  shortcut,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- CATEGORY CHIP (MATCHING REFERENCE 2_POS.png) ---
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF334155)),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

// --- PAGINATION (MATCHING REFERENCE) ---
class PosPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PosPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageNavBtn(context, Icons.chevron_left, currentPage > 1 ? () => onPageChanged(currentPage - 1) : null),
        const SizedBox(width: 12),
        Text("Page $currentPage of $totalPages", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6))),
        const SizedBox(width: 12),
        _pageNavBtn(context, Icons.chevron_right, currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null),
      ],
    );
  }

  Widget _pageNavBtn(BuildContext context, IconData icon, VoidCallback? onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: onTap == null ? theme.dividerColor.withOpacity(0.1) : theme.cardColor,
        ),
        child: Icon(icon, size: 18, color: onTap == null ? theme.textTheme.bodySmall?.color?.withOpacity(0.4) : theme.textTheme.bodyMedium?.color),
      ),
    );
  }
}
