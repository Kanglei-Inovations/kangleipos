import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../common/glass_panel.dart';
import 'sidebar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1180;
    final isTablet = size.width >= 768 && size.width < 1180;
    final isMobile = size.width < 768;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isTablet ? const Sidebar(isMobile: true) : null,
      bottomNavigationBar: isMobile ? const _MobileNavigation() : null,
      floatingActionButton: const _PremiumFloatingButton(),
      body: Stack(
        children: [
          const _DashboardBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isDesktop ? 18 : 14,
                14,
                isDesktop ? 18 : 14,
                isMobile ? 90 : 18,
              ),
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
                  if (isDesktop) const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _PremiumHeader(
                          title: widget.title,
                          isMobile: isMobile,
                          isTablet: isTablet,
                          onMenuPressed: isTablet
                              ? () => Scaffold.of(context).openDrawer()
                              : null,
                        ),
                        SizedBox(height: isMobile ? 14 : 18),
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
                              child: widget.child,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  final String title;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback? onMenuPressed;

  const _PremiumHeader({
    required this.title,
    required this.isMobile,
    required this.isTablet,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel(
      borderRadius: BorderRadius.circular(28),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      color: isDark
          ? const Color(0xFF111827).withOpacity(0.58)
          : Colors.white.withOpacity(0.66),
      child: isMobile ? _buildMobileHeader(context) : _buildWideHeader(context),
    );
  }

  Widget _buildWideHeader(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(
          icon: isTablet ? Icons.menu_rounded : Icons.dashboard_customize_rounded,
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
        const SizedBox(width: 18),
        const _HeaderActions(),
      ],
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _HeaderIconButton(
              icon: Icons.dashboard_customize_rounded,
              onTap: onMenuPressed,
            ),
            const SizedBox(width: 12),
            Expanded(child: _HeaderTitle(title: title, compact: true)),
            const _HeaderActions(compact: true),
          ],
        ),
        const SizedBox(height: 12),
        const _GlobalSearchBar(),
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
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.58)
            : Colors.white.withOpacity(0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.10)
              : const Color(0xFFCBD5E1).withOpacity(0.92),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: muted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search anything...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Ctrl + K',
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w800,
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
        const SizedBox(width: 10),
        const _HeaderIconButton(icon: Icons.fullscreen_rounded),
        const SizedBox(width: 10),
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
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1,
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hovering
                  ? AppTheme.primaryColor.withOpacity(0.12)
                  : isDark
                  ? const Color(0xFF1E293B).withOpacity(0.58)
                  : Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovering
                    ? AppTheme.primaryColor.withOpacity(0.24)
                    : isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFCBD5E1).withOpacity(0.82),
              ),
            ),
            child: Icon(widget.icon, size: 21),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _HeaderIconButton(icon: Icons.notifications_none_rounded),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppTheme.dangerColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '5',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
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
    final muted = isDark ? AppTheme.darkMutedTextColor : AppTheme.lightMutedTextColor;

    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.58)
            : Colors.white.withOpacity(0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFCBD5E1).withOpacity(0.82),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD29D), Color(0xFFFF8A80)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 17, color: Colors.white),
          ),
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
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down_rounded, color: muted, size: 20),
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
      offset: const Offset(0, 12),
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
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
                fontSize: 18,
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
    final destinations = [
      (Icons.dashboard_rounded, 'Dashboard', AppRoutes.DASHBOARD),
      (Icons.point_of_sale_rounded, 'POS', AppRoutes.POS),
      (Icons.inventory_2_rounded, 'Inventory', AppRoutes.INVENTORY),
      (Icons.analytics_rounded, 'Reports', AppRoutes.REPORTS),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: GlassPanel(
        height: 72,
        borderRadius: BorderRadius.circular(26),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final item in destinations)
              _MobileNavItem(
                icon: item.$1,
                label: item.$2,
                selected: currentRoute == item.$3,
                onTap: () {
                  if (currentRoute == item.$3) return;
                  if (item.$3 == AppRoutes.REPORTS) {
                    Get.snackbar('Reports', 'Reports module is coming soon');
                    return;
                  }
                  Get.offNamed(item.$3);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withOpacity(0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppTheme.primaryColor : null,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppTheme.primaryColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFloatingButton extends StatelessWidget {
  const _PremiumFloatingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.42),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add_rounded, size: 34),
      ),
    );
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
            Color(0xFF0B1120),
            Color(0xFF0F172A),
            Color(0xFF111827),
          ]
              : const [
            Color(0xFFF8FBFF),
            Color(0xFFF3F7FF),
            Color(0xFFEFF6FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _SoftGlow(
              color: isDark
                  ? AppTheme.primaryColor.withOpacity(0.22)
                  : const Color(0xFF93C5FD).withOpacity(0.36),
              size: 360,
            ),
          ),
          Positioned(
            bottom: -180,
            left: 180,
            child: _SoftGlow(
              color: isDark
                  ? AppTheme.accentColor.withOpacity(0.16)
                  : const Color(0xFFC4B5FD).withOpacity(0.32),
              size: 420,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftGlow({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}