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
          padding: const EdgeInsets.all(12),
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
                            errorBuilder: (_, __, ___) => Icon(Icons.image, size: 50, color: theme.dividerColor),
                          ),
                        )
                      : Icon(Icons.image, size: 50, color: theme.dividerColor),
                ),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              Text(
                "₹ ${NumberFormat('#,##,###.00').format(widget.product.price)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: isOutOfStock ? Colors.red : Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        isOutOfStock ? "Out of Stock" : "In Stock",
                        style: TextStyle(fontSize: 11, color: isOutOfStock ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.product.stockQuantity.toInt()}",
                    style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
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
            child: Row(
              children: [
                _qtyBtn(context, Icons.remove, () => onUpdateQuantity(-1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "${item.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                _qtyBtn(context, Icons.add, () => onUpdateQuantity(1)),
              ],
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

// --- CHECKOUT AREA (MATCHING REFERENCE) ---
class CheckoutAction extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Received Amount", style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: TextEditingController(text: receivedAmount.toStringAsFixed(0)),
                    onChanged: (v) {
                      final pos = Get.find<PosController>();
                      pos.receivedAmount.value = double.tryParse(v) ?? 0;
                    },
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Change to Return", style: TextStyle(fontSize: 12, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text(
                      "₹ ${NumberFormat('#,##,###.00').format(math.max(0.0, receivedAmount - amount))}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Pay / Checkout (F8)", style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
          ),
        )
      ],
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
