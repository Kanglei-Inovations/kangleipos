import 'package:flutter/material.dart';

class MasterFilterBar extends StatelessWidget {
  final Function(String) onSearch;
  final String? selectedCategory;
  final String? selectedBrand;

  const MasterFilterBar({
    super.key,
    required this.onSearch,
    this.selectedCategory,
    this.selectedBrand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Search products, SKU, category, brand...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFF9FAFB),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterDropdown('Category', ['All Categories', 'Electronics', 'Grocery']),
          const SizedBox(width: 12),
          _buildFilterDropdown('Brand', ['All Brands', 'Samsung', 'Apple']),
          const SizedBox(width: 12),
          _buildFilterDropdown('Status', ['All Status', 'Active', 'Inactive']),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'More Filters',
          ),
          const VerticalDivider(width: 24),
          _buildSortDropdown(),
          const SizedBox(width: 12),
          _buildLayoutToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.sort_rounded, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        const Text('Sort by', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 4),
        DropdownButton<String>(
          value: 'Newest',
          underline: const SizedBox(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          items: ['Newest', 'Oldest', 'Price High', 'Price Low'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) {},
        ),
      ],
    );
  }

  Widget _buildLayoutToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _toggleButton(Icons.view_list_rounded, true),
          _toggleButton(Icons.grid_view_rounded, false),
        ],
      ),
    );
  }

  Widget _toggleButton(IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
      ),
      child: Icon(icon, size: 18, color: active ? Colors.blue : Colors.grey),
    );
  }
}
