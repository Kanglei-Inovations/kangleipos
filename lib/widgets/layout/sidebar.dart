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
    final width = isMobile ? 280.0 : (isCollapsed ? 82.0 : 260.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Professional ERP Dark Navy color
    const Color sidebarDarkBg = Color(0xFF0F172A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: sidebarDarkBg,
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _SidebarLogo(
              isCollapsed: isCollapsed && !isMobile,
              onToggle: onToggle,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Theme(
              data: theme.copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    Colors.white.withValues(alpha: 0.1),
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
          // Fixed bottom section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (!(isCollapsed && !isMobile)) ...[
                  const _SystemStatusCard(),
                  const SizedBox(height: 12),
                  const _UserCard(),
                ] else ...[
                  _buildCollapsedIndicator(
                      context, Icons.wifi_rounded, Colors.greenAccent),
                  const SizedBox(height: 12),
                  _buildCollapsedIndicator(
                      context, Icons.person_rounded, AppTheme.primaryColor),
                ],
              ],
            ),
          ),
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

  const _MenuEntry(this.icon, this.title, this.route);
}

final List<_SidebarItem> _menuItems = [
  const _MenuHeader('CORE'),
  const _MenuEntry(Icons.dashboard_rounded, 'Dashboard', AppRoutes.DASHBOARD),
  const _MenuEntry(Icons.point_of_sale_rounded, 'POS / Billing', AppRoutes.POS),
  const _MenuEntry(Icons.history_rounded, 'Sales', AppRoutes.SALES),
  
  const _MenuHeader('INVENTORY'),
  const _MenuEntry(Icons.shopping_bag_outlined, 'Products', AppRoutes.PRODUCTS_MASTER),
  const _MenuEntry(Icons.inventory_2_rounded, 'Inventory', AppRoutes.INVENTORY),
  const _MenuEntry(Icons.shopping_bag_rounded, 'Purchases', AppRoutes.PURCHASES),
  const _MenuEntry(Icons.diversity_3_rounded, 'Suppliers', AppRoutes.SUPPLIERS),
  
  const _MenuHeader('FINANCE & CRM'),
  const _MenuEntry(Icons.account_balance_wallet_rounded, 'Expenses', AppRoutes.EXPENSES),
  const _MenuEntry(Icons.groups_2_rounded, 'Customers', AppRoutes.CUSTOMERS),
  const _MenuEntry(Icons.analytics_rounded, 'Reports', AppRoutes.REPORTS),
  const _MenuEntry(Icons.verified_user_rounded, 'GST / Tax', AppRoutes.GST),
  
  const _MenuHeader('SYSTEM'),
  const _MenuEntry(Icons.manage_accounts_rounded, 'Users', AppRoutes.USERS),
  const _MenuEntry(Icons.settings_rounded, 'Settings', AppRoutes.SETTINGS),
  const _MenuEntry(Icons.cloud_upload_rounded, 'Backup & Restore', AppRoutes.BACKUP),
  const _MenuEntry(Icons.sync_rounded, 'Sync Center', AppRoutes.SYNC),
];

class _SidebarHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;

  const _SidebarHeader({required this.title, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(
            color: Colors.white.withValues(alpha: 0.05),
            indent: 16,
            endIndent: 16),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
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

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF38BDF8),
                Color(0xFF6366F1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enterprise ERP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _TinyIconButton(
            icon: Icons.menu_open_rounded,
            onTap: onToggle,
            dark: true,
          ),
        ] else if (onToggle != null) ...[
          const Spacer(),
          _TinyIconButton(
            icon: Icons.menu_rounded,
            onTap: onToggle,
            dark: true,
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

  @override
  Widget build(BuildContext context) {
    final route = widget.entry.route;
    final isSelected = route != null && Get.currentRoute == route;
    final showLabel = !widget.isCollapsed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (widget.isMobile) Get.back();
            if (route == null) {
              Get.snackbar(
                widget.entry.title,
                '${widget.entry.title} module is coming soon',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
                colorText: Colors.white,
              );
              return;
            }
            if (!isSelected) Get.offNamed(route);
          },
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: showLabel ? 16 : 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.12)
                      : _hovering
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: showLabel
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.entry.icon,
                      size: 20,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withValues(alpha: 0.55),
                    ),
                    if (showLabel) ...[
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.65),
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ).animate().fadeIn(duration: 300.ms).slideX(
                            begin: -0.5, end: 0)
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  left: 0,
                  top: 12,
                  bottom: 12,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4)),
                    ),
                  ),
                ).animate().scaleY(
                    begin: 0,
                    end: 1,
                    duration: 250.ms,
                    curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_rounded,
                color: Colors.greenAccent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM ONLINE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Connected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Super Admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Online Now',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
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
            dark: true,
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: const Icon(icon, color: Colors.white70, size: 17),
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
