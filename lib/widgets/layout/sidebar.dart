import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  final bool isMobile;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const Sidebar({
    super.key,
    required this.isMobile,
    this.isCollapsed = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final width = isMobile ? 280.0 : (isCollapsed ? 100.0 : 280.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1120) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _SidebarLogo(
              isCollapsed: isCollapsed && !isMobile,
              onToggle: onToggle,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Theme(
              data: theme.copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                  thickness: WidgetStateProperty.all(4),
                  radius: const Radius.circular(10),
                ),
              ),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    if (item is _MenuHeader) {
                      return _SidebarHeader(
                        title: item.title,
                        isCollapsed: isCollapsed && !isMobile,
                      );
                    } else if (item is _MenuEntry) {
                      return _SidebarMenuItem(
                        entry: item,
                        isCollapsed: isCollapsed && !isMobile,
                        isMobile: isMobile,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          if (!(isCollapsed && !isMobile)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const _SystemStatusCard(),
                  const SizedBox(height: 12),
                  const _UserCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            _buildCollapsedIndicator(
                context, Icons.wifi_rounded, Colors.greenAccent),
            const SizedBox(height: 12),
            _buildCollapsedIndicator(
                context, Icons.person_rounded, AppTheme.primaryColor),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsedIndicator(
      BuildContext context, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.4),
        ),
      ),
      child: Icon(icon,
          color: isDark ? color : color.withValues(alpha: 0.8), size: 20),
    ).animate().scale(duration: 300.ms);
  }
}

abstract class _SidebarItem {
  const _SidebarItem();
}

class _MenuHeader extends _SidebarItem {
  final String title;
  const _MenuHeader(this.title);
}

class _MenuEntry extends _SidebarItem {
  final IconData icon;
  final String title;
  final String? route;
  final List<_MenuEntry>? subItems;

  const _MenuEntry(this.icon, this.title, this.route, {this.subItems});
}

final List<_SidebarItem> _menuItems = [
  const _MenuHeader('CORE'),
  const _MenuEntry(Icons.dashboard_rounded, 'Dashboard', AppRoutes.DASHBOARD),
  const _MenuEntry(Icons.point_of_sale_rounded, 'POS / Billing', AppRoutes.POS),
  const _MenuEntry(Icons.history_rounded, 'Sales', AppRoutes.SALES),
  const _MenuHeader('INVENTORY'),
  const _MenuEntry(Icons.shopping_bag_outlined, 'Products', null, subItems: [
    _MenuEntry(Icons.list_rounded, 'All Products', AppRoutes.INVENTORY),
    _MenuEntry(Icons.add_box_rounded, 'Add New Product', null),
    _MenuEntry(Icons.grid_view_rounded, 'Product Overview', null),
    _MenuEntry(Icons.storage_rounded, 'Master Data', AppRoutes.PRODUCTS_MASTER),
    _MenuEntry(Icons.adjust_rounded, 'Stock Adjustment', AppRoutes.STOCK_ADJUSTMENT),
    _MenuEntry(Icons.swap_horiz_rounded, 'Stock Transfer', AppRoutes.STOCK_TRANSFER),
  ]),
  const _MenuEntry(Icons.shopping_bag_rounded, 'Purchases', AppRoutes.PURCHASES),
  const _MenuEntry(Icons.diversity_3_rounded, 'Suppliers', AppRoutes.SUPPLIERS),
  const _MenuHeader('FINANCE & CRM'),
  const _MenuEntry(
      Icons.account_balance_wallet_rounded, 'Expenses', AppRoutes.EXPENSES),
  const _MenuEntry(Icons.verified_user_rounded, 'GST / Tax', AppRoutes.GST),
  const _MenuEntry(Icons.analytics_rounded, 'Reports', AppRoutes.REPORTS),
  const _MenuEntry(Icons.groups_2_rounded, 'Customers', AppRoutes.CUSTOMERS),
  const _MenuHeader('SYSTEM'),
  const _MenuEntry(Icons.manage_accounts_rounded, 'Users', AppRoutes.USERS),
  const _MenuEntry(Icons.settings_rounded, 'Settings', AppRoutes.SETTINGS),
  const _MenuEntry(
      Icons.cloud_upload_rounded, 'Backup & Restore', AppRoutes.BACKUP),
  const _MenuEntry(Icons.sync_rounded, 'Sync Center', AppRoutes.SYNC),
];

class _SidebarHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;

  const _SidebarHeader({required this.title, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            indent: 16,
            endIndent: 16),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.8,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _SidebarLogo extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const _SidebarLogo({
    required this.isCollapsed,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final db = Get.find<AppDatabase>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _HoverLift(
          lift: 2,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF38BDF8),
                  Color(0xFF6366F1),
                  Color(0xFF9333EA)
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
          ),
        ),
        if (!isCollapsed) ...[
          const SizedBox(width: 14),
          Expanded(
            child: FutureBuilder<Setting?>(
              future: (db.select(db.settings)
                    ..where((t) => t.key.equals('business_name')))
                  .getSingleOrNull(),
              builder: (context, snapshot) {
                final businessName = snapshot.data?.value ?? 'KANGLEI POS';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      businessName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enterprise ERP',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          _TinyIconButton(
            icon: Icons.menu_open_rounded,
            onTap: onToggle,
            dark: isDark,
          ),
        ] else if (onToggle != null) ...[
          const Spacer(),
          _TinyIconButton(
            icon: Icons.menu_rounded,
            onTap: onToggle,
            dark: isDark,
          ),
        ],
      ],
    );
  }
}

class _SidebarMenuItem extends StatefulWidget {
  final _MenuEntry entry;
  final bool isCollapsed;
  final bool isMobile;

  const _SidebarMenuItem({
    required this.entry,
    required this.isCollapsed,
    required this.isMobile,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _hovering = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.entry.route;
    final isSelected = route != null && Get.currentRoute == route;
    final showLabel = !widget.isCollapsed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSubItems = widget.entry.subItems != null && widget.entry.subItems!.isNotEmpty;
    
    // Check if any sub-item is selected
    final isAnySubSelected = hasSubItems && widget.entry.subItems!.any((s) => s.route != null && Get.currentRoute == s.route);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.02 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  if (hasSubItems) {
                    setState(() => _isExpanded = !_isExpanded);
                    return;
                  }
                  if (widget.isMobile) Get.back();
                  if (route == null) {
                    Get.snackbar(
                      widget.entry.title,
                      '${widget.entry.title} module is coming soon',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor:
                          AppTheme.primaryColor.withValues(alpha: 0.9),
                      colorText: Colors.white,
                    );
                    return;
                  }
                  if (!isSelected) Get.offNamed(route);
                },
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      height: 52,
                      padding:
                          EdgeInsets.symmetric(horizontal: showLabel ? 16 : 0),
                      decoration: BoxDecoration(
                        gradient: (isSelected || isAnySubSelected)
                            ? const LinearGradient(
                                colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: (isSelected || isAnySubSelected)
                            ? null
                            : _hovering
                                ? (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05))
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (isSelected || isAnySubSelected)
                              ? Colors.white.withValues(alpha: 0.2)
                              : (isDark
                                  ? Colors.white
                                      .withValues(alpha: _hovering ? 0.05 : 0.0)
                                  : Colors.black.withValues(
                                      alpha: _hovering ? 0.05 : 0.0)),
                        ),
                        boxShadow: (isSelected || isAnySubSelected)
                            ? [
                                const BoxShadow(
                                  color: Color(0x666366F1),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: showLabel
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.entry.icon,
                            size: 22,
                            color: (isSelected || isAnySubSelected)
                                ? Colors.white
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.black.withValues(alpha: 0.6)),
                          ),
                          if (showLabel) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                widget.entry.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: (isSelected || isAnySubSelected)
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : Colors.black.withValues(alpha: 0.7)),
                                  fontSize: 14,
                                  fontWeight: (isSelected || isAnySubSelected)
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (hasSubItems)
                               Icon(
                                _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: (isSelected || isAnySubSelected) ? Colors.white70 : Colors.grey,
                              )
                            else if (isSelected)
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Colors.white,
                              ).animate().fadeIn(duration: 400.ms).slideX(
                                  begin: -0.5, end: 0)
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.2),
                              ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected || isAnySubSelected)
                      Positioned(
                        left: 0,
                        top: 15,
                        bottom: 15,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4)),
                            boxShadow: [
                              const BoxShadow(
                                color: Color(0xCC38BDF8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ).animate().scaleY(
                          begin: 0,
                          end: 1,
                          duration: 300.ms,
                          curve: Curves.elasticOut),
                  ],
                ),
              ),
            ),
            if (hasSubItems && _isExpanded && !widget.isCollapsed)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: widget.entry.subItems!.map((sub) {
                    final isSubSelected = sub.route != null && Get.currentRoute == sub.route;
                    return _SidebarSubMenuItem(entry: sub, isSelected: isSubSelected, isMobile: widget.isMobile);
                  }).toList(),
                ),
              ).animate().fadeIn(duration: 200.ms),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
        begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

class _SidebarSubMenuItem extends StatelessWidget {
  final _MenuEntry entry;
  final bool isSelected;
  final bool isMobile;

  const _SidebarSubMenuItem({required this.entry, required this.isSelected, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        if (isMobile) Get.back();
        if (entry.route != null) Get.offNamed(entry.route!);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(entry.icon, size: 16, color: isSelected ? theme.primaryColor : (isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? theme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: isDark ? 0.1 : 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_rounded,
                color: Colors.greenAccent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM ONLINE',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'LAN Connected',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.greenAccent, blurRadius: 8),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 800.ms),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Online Now',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _TinyIconButton(
            icon: Icons.logout_rounded,
            onTap: () {
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().logout();
              }
            },
            dark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  final IconData icon;
  final bool dark;
  final VoidCallback? onTap;

  const _TinyIconButton({
    required this.icon,
    this.dark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(icon, color: dark ? Colors.white70 : Colors.black87, size: 18),
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double lift;

  const _HoverLift({
    required this.child,
    this.lift = 5,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.05 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _hovering ? Offset(0, -widget.lift / 100) : Offset.zero,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
