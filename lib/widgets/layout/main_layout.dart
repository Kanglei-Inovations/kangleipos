import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import 'sidebar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final Widget? headerAction;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.headerAction,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1180;
    final isTablet = size.width >= 768 && size.width < 1180;
    final isMobile = size.width < 768;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: isTablet ? const Sidebar(isMobile: true) : null,
      bottomNavigationBar: isMobile ? const _MobileNavigation() : null,
      body: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDesktop)
              Sidebar(
                isMobile: false,
                isCollapsed: _sidebarCollapsed,
                onToggle: () {
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                },
              ),
            Expanded(
              child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (!isMobile)
                    _PremiumHeader(
                      title: widget.title,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      headerAction: widget.headerAction,
                      onMenuPressed: isTablet
                          ? () => Scaffold.of(context).openDrawer()
                          : null,
                    ),
                  Expanded(
                    child: PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 420),
                      transitionBuilder:
                          (child, animation, secondaryAnimation) {
                        return FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          fillColor: Colors.transparent,
                          child: child,
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(widget.title),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: isMobile ? 12 : 24,
                            right: isMobile ? 12 : 24,
                            top: isMobile ? 12 : 8,
                            bottom: isMobile ? 12 : 20,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class _PremiumHeader extends StatelessWidget {
  final String title;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback? onMenuPressed;
  final Widget? headerAction;

  const _PremiumHeader({
    required this.title,
    required this.isMobile,
    required this.isTablet,
    this.onMenuPressed,
    this.headerAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      height: isMobile ? 56 : 72,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 0 : 0,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: isMobile ? BorderRadius.zero : const BorderRadius.only(topLeft: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: isMobile ? _buildMobileHeader(context) : _buildWideHeader(context),
    );
  }

  Widget _buildWideHeader(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(
          icon:
              isTablet ? Icons.menu_rounded : Icons.dashboard_customize_rounded,
          onTap: onMenuPressed,
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: _HeaderTitle(title: title),
        ),
        const SizedBox(width: 18),
        const Expanded(
          flex: 5,
          child: _GlobalSearchBar(),
        ),
        if (headerAction != null) ...[
          const SizedBox(width: 16),
          headerAction!,
        ],
        const SizedBox(width: 18),
        const _HeaderActions(),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

    return Row(
      children: [
        if (canPop)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            onPressed: () => Navigator.maybePop(context),
            splashRadius: 20,
          )
        else
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 17),
          ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        if (headerAction != null) ...[
          headerAction!,
          const SizedBox(width: 4),
        ],
        const _NotificationButton(),
      ],
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  final String title;
  final bool compact;

  const _HeaderTitle({
    required this.title,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.brightness == Brightness.dark
        ? AppTheme.darkMutedTextColor
        : AppTheme.lightMutedTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title == 'Dashboard' ? 'Welcome back, Admin!' : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: compact ? 18 : 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            height: 1.05,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 6),
          Text(
            "Here's what's happening with your business today.",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _GlobalSearchBar extends StatelessWidget {
  const _GlobalSearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted =
        isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: muted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search anything...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              'Ctrl + K',
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final bool compact;

  const _HeaderActions({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<AppThemeController>();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderIconButton(
            icon: themeController.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _NotificationButton(),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          icon: themeController.isDarkMode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          onTap: themeController.toggleTheme,
        ),
        const SizedBox(width: 8),
        const _HeaderIconButton(icon: Icons.fullscreen_rounded),
        const SizedBox(width: 8),
        _NotificationButton(),
        const SizedBox(width: 12),
        const _StoreSelector(),
        const SizedBox(width: 12),
        const _DateSelector(),
        const SizedBox(width: 12),
        const _ProfileMenu(),
      ],
    );
  }
}

class _HeaderIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hovering
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFF1F5F9))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovering
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFE2E8F0))
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _HeaderIconButton(icon: Icons.notifications_none_rounded),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.dangerColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F172A)
                    : Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreSelector extends StatelessWidget {
  const _StoreSelector();

  @override
  Widget build(BuildContext context) {
    return _HeaderPill(
      icon: Icons.storefront_rounded,
      title: 'Main Store',
      subtitle: '2024-2025',
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    return _HeaderPill(
      icon: Icons.calendar_month_rounded,
      title: 'May 24, 2025',
      subtitle: 'This Month',
      compact: true,
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  const _HeaderPill({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted =
        isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          if (!compact) const SizedBox(width: 10),
          if (!compact)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down_rounded, color: muted, size: 16),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      offset: const Offset(0, 8),
      onSelected: (value) {
        if (value == 'logout') {
          if (Get.isRegistered<AuthController>()) {
            Get.find<AuthController>().logout();
          } else {
            Get.offAllNamed('/auth');
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Obx(() {
            final auth = Get.isRegistered<AuthController>()
                ? Get.find<AuthController>()
                : null;
            final name = auth?.currentUserName.value ?? 'A';
            return Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation();

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final destinations = [
      (Icons.home_rounded, Icons.home_outlined, 'Dashboard', AppRoutes.DASHBOARD),
      (Icons.swap_horiz_rounded, Icons.swap_horiz_rounded, 'Transactions', AppRoutes.SALES),
      (Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'POS', AppRoutes.POS),
      (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Reports', AppRoutes.REPORTS),
      (Icons.settings_rounded, Icons.settings_outlined, 'Settings', AppRoutes.SETTINGS),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in destinations)
                _MobileNavItem(
                  activeIcon: item.$1,
                  inactiveIcon: item.$2,
                  label: item.$3,
                  selected: currentRoute == item.$4 ||
                      (item.$4 == AppRoutes.SALES && currentRoute == AppRoutes.PAYMENTS),
                  onTap: () {
                    if (currentRoute == item.$4) return;
                    Get.offNamed(item.$4);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryAccent = Color(0xFF4F46E5);
    const unselectedColor = Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? primaryAccent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? activeIcon : inactiveIcon,
                size: 22,
                color: selected ? primaryAccent : unselectedColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? primaryAccent : unselectedColor,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
