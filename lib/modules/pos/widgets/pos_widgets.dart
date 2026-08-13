import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../../database/database.dart';
import '../controllers/pos_controller.dart';
import '../models/cart_item.dart';

// --- PRODUCT CARD (MATCHING REFERENCE) ---
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
    final bool isOutOfStock = (widget.product.stockQuantity) <= 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: isOutOfStock ? null : widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isHovered ? theme.colorScheme.primary : theme.dividerColor),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.image, size: 36, color: theme.dividerColor),
                          ),
                        )
                      : Icon(Icons.image, size: 36, color: theme.dividerColor),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.product.description ?? "Standard Variant",
                style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                "₹ ${NumberFormat('#,##,###.00').format(widget.product.price)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 3.5, backgroundColor: isOutOfStock ? Colors.red : Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          isOutOfStock ? "Out of Stock" : "In Stock",
                          style: TextStyle(fontSize: 11, color: isOutOfStock ? Colors.red : Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Qty: ${widget.product.stockQuantity.toInt()}",
                      style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- CART ITEM ROW (MATCHING REFERENCE) ---
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "$index",
              style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8), fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(item.product.imageUrl!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.smartphone, size: 20, color: theme.dividerColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.product.description ?? "Standard Variant",
                        style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Text(
              "₹ ${NumberFormat('#,##,###').format(item.product.price)}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  _qtyBtn(context, Icons.remove, () => onUpdateQuantity(-1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      "${item.quantity}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  _qtyBtn(context, Icons.add, () => onUpdateQuantity(1)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              "₹ ${NumberFormat('#,##,###.00').format(item.total)}",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 35,
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

// --- BILL SUMMARY ROW (MATCHING REFERENCE) ---
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isDiscount ? Colors.green : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOMER SELECTOR (MATCHING REFERENCE) ---
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCustomer?.name ?? 'Walk-in Customer',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    selectedCustomer?.phone ?? 'Default',
                    style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 16),
            InkWell(
              onTap: onAddCustomer,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- SEARCH BAR (MATCHING REFERENCE) ---
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: "Scan barcode or search product...",
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: InkWell(onTap: onBarcodeTap, child: const Icon(Icons.qr_code_scanner)),
              filled: true,
              fillColor: theme.cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Text("All Categories", style: TextStyle(fontSize: 14)),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_alt_outlined),
          ),
        ),
      ],
    );
  }
}

// --- INVOICE TAB (MATCHING REFERENCE) ---
class PosInvoiceTab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const PosInvoiceTab({
    super.key,
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.description_outlined,
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color?.withOpacity(0.6), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: theme.colorScheme.error,
                child: Text(badge!,
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// --- CHECKOUT AREA ---
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

  // Split field controllers
  final Map<String, TextEditingController> _splitCtrls = {
    'Cash': TextEditingController(),
    'UPI': TextEditingController(),
    'Due': TextEditingController(),
    'Payment Gateway': TextEditingController(),
  };

  static const _methods = ['Cash', 'Due', 'UPI', 'Payment Gateway', 'Split'];
  static const _splitMethods = ['Cash', 'UPI', 'Due', 'Payment Gateway'];

  static const Map<String, IconData> _methodIcons = {
    'Cash': Icons.payments_outlined,
    'Due': Icons.account_balance_wallet_outlined,
    'UPI': Icons.phone_android_outlined,
    'Payment Gateway': Icons.credit_card_outlined,
    'Split': Icons.call_split_rounded,
  };

  @override
  void initState() {
    super.initState();
    _receivedCtrl = TextEditingController(
      text: widget.receivedAmount == 0 ? '' : widget.receivedAmount.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant CheckoutAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receivedAmount != widget.receivedAmount) {
      final txt = widget.receivedAmount == 0 ? '' : widget.receivedAmount.toStringAsFixed(0);
      if (_receivedCtrl.text != txt) _receivedCtrl.text = txt;
    }
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
    final pos = Get.find<PosController>();
    final total = widget.amount;

    return Obx(() {
      final method = pos.selectedPaymentMethod.value;
      final isDue = method == 'Due';
      final isSplit = method == 'Split';

      // Compute effective received for status display
      double received;
      if (isDue) {
        received = 0.0;
      } else if (isSplit) {
        received = pos.splitAmounts.values.fold(0.0, (a, b) => a + b);
      } else {
        received = pos.receivedAmount.value;
      }

      final due = math.max(0.0, total - received);
      final change = math.max(0.0, received - total);

      Color statusColor;
      String statusLabel;
      String statusValue;

      if (isDue) {
        statusColor = Colors.red;
        statusLabel = 'Full Amount DUE';
        statusValue = '₹ ${NumberFormat('#,##,###.00').format(total)}';
      } else if (received >= total && total > 0) {
        statusColor = Colors.green;
        statusLabel = 'Change to Return';
        statusValue = '₹ ${NumberFormat('#,##,###.00').format(change)}';
      } else if (received > 0 && received < total) {
        statusColor = Colors.orange;
        statusLabel = 'Remaining DUE';
        statusValue = '₹ ${NumberFormat('#,##,###.00').format(due)}';
      } else {
        statusColor = Colors.red;
        statusLabel = isSplit ? 'Split Not Filled' : 'Full Amount DUE';
        statusValue = '₹ ${NumberFormat('#,##,###.00').format(total)}';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Payment Method Selector ──
          Text('Payment Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _methods.map((m) {
              final sel = method == m;
              return GestureDetector(
                onTap: () => pos.selectedPaymentMethod.value = m,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? theme.colorScheme.primary : theme.cardColor,
                    border: Border.all(
                      color: sel ? theme.colorScheme.primary : theme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_methodIcons[m], size: 15,
                          color: sel ? Colors.white : theme.textTheme.bodySmall?.color),
                      const SizedBox(width: 5),
                      Text(m, style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : theme.textTheme.bodyMedium?.color,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Input Section ──
          if (!isDue && !isSplit) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Received Amount',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodySmall?.color)),
                          GestureDetector(
                            onTap: () {
                              pos.receivedAmount.value = total;
                              _receivedCtrl.text = total.toStringAsFixed(0);
                            },
                            child: Text(
                              'Exact Pay (₹${total.toStringAsFixed(0)})',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _receivedCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) => pos.receivedAmount.value = double.tryParse(v) ?? 0.0,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '₹ ',
                          fillColor: theme.cardColor,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _StatusBox(label: statusLabel, value: statusValue, color: statusColor),
                ),
              ],
            ),
          ] else if (isDue) ...[
            _StatusBox(label: statusLabel, value: statusValue, color: statusColor),
            const SizedBox(height: 4),
            Text(
              'Customer will be credited for full amount. Select a customer to record this due.',
              style: TextStyle(fontSize: 11, color: Colors.red.shade400),
            ),
          ] else if (isSplit) ...[
            // Split panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Split Amount Entry',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                  const SizedBox(height: 10),
                  ..._splitMethods.map((sm) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                Icon(_methodIcons[sm], size: 14,
                                    color: theme.textTheme.bodySmall?.color),
                                const SizedBox(width: 6),
                                Text(sm,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _splitCtrls[sm],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (v) {
                                pos.splitAmounts[sm] = double.tryParse(v) ?? 0.0;
                              },
                              decoration: InputDecoration(
                                hintText: '0',
                                prefixText: '₹ ',
                                isDense: true,
                                filled: true,
                                fillColor: theme.cardColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 16),
                  Obx(() {
                    final splitTotal = pos.splitAmounts.values.fold(0.0, (a, b) => a + b);
                    final remaining = total - splitTotal;
                    final overPaid = splitTotal > total;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Split Total: ₹${splitTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: overPaid ? Colors.red : theme.textTheme.bodyMedium?.color)),
                        Text(
                          overPaid
                              ? 'Over by ₹${(splitTotal - total).toStringAsFixed(2)}'
                              : remaining > 0
                                  ? 'Remaining: ₹${remaining.toStringAsFixed(2)}'
                                  : '✓ Fully covered',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: overPaid
                                  ? Colors.red
                                  : remaining > 0
                                      ? Colors.orange
                                      : Colors.green),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Checkout Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDue
                    ? Colors.red.shade600
                    : received >= total && total > 0
                        ? Colors.green
                        : received > 0
                            ? Colors.orange
                            : isSplit
                                ? theme.colorScheme.primary
                                : AppTheme.primaryColor,
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
                                  : Icons.access_time_rounded,
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
                                        ? 'Complete Paid Sale'
                                        : received > 0
                                            ? 'Partial Sale (Due ₹${due.toStringAsFixed(0)})'
                                            : 'Submit as DUE (₹${total.toStringAsFixed(0)})',
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

// ── Status display box ──
class _StatusBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }
}


// --- QUICK SHORTCUT ITEM (MATCHING REFERENCE) ---
class QuickShortcutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String shortcut;
  final VoidCallback onTap;

  const QuickShortcutItem({
    super.key,
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(shortcut,
              style: TextStyle(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- CATEGORY CHIP (MATCHING REFERENCE) ---
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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected ? theme.colorScheme.primary : theme.cardColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
          side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.dividerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
