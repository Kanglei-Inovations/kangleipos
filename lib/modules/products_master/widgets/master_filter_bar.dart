import 'package:flutter/material.dart';

class MasterFilterBar extends StatelessWidget {
  final Function(String) onSearch;

  const MasterFilterBar({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search products, SKU, category, brand...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.dividerColor.withOpacity(0.05),
                border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown(context, 'Category', ['All Categories']),
          const SizedBox(width: 12),
          _buildFilterDropdown(context, 'Brand', ['All Brands']),
          const SizedBox(width: 12),
          _buildFilterDropdown(context, 'Unit', ['All Units']),
          const SizedBox(width: 12),
          _buildFilterDropdown(context, 'Status', ['All Status']),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'More Filters',
          ),
          VerticalDivider(width: 24, color: theme.dividerColor),
          _buildSortDropdown(context),
          const SizedBox(width: 12),
          _buildLayoutToggle(context),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context, String label, List<String> items) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color)),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, size: 16, color: theme.textTheme.bodySmall?.color),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sort_rounded, size: 20, color: theme.textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Text('Sort by', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
        const SizedBox(width: 4),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: 'Newest',
            dropdownColor: theme.cardColor,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            items: ['Newest', 'Oldest', 'Price High', 'Price Low'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }

  Widget _buildLayoutToggle(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _toggleButton(context, Icons.view_list_rounded, true),
          _toggleButton(context, Icons.grid_view_rounded, false),
        ],
      ),
    );
  }

  Widget _toggleButton(BuildContext context, IconData icon, bool active) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? theme.cardColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: active && theme.brightness == Brightness.light ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
      ),
      child: Icon(icon, size: 18, color: active ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color),
    );
  }
}
