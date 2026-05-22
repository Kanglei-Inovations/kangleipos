import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _ambientController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  String _pin = '';
  bool _rememberDevice = true;
  bool _rememberPin = false;
  bool _pinError = false;

  AuthController get controller => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _emailController = TextEditingController(text: 'admin@mainstore.com');
    _passwordController = TextEditingController(text: '1234');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ambientController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitPassword() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    controller.loginWithPassword(
      usernameOrEmail: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _submitPin() {
    if (_pin.length < 4) {
      HapticFeedback.mediumImpact();
      setState(() => _pinError = true);
      Future.delayed(const Duration(milliseconds: 420), () {
        if (mounted) setState(() => _pinError = false);
      });
      return;
    }

    controller.loginWithPin(_pin);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _pin = '');
    });
  }

  void _onPinKey(String value) {
    if (_pin.length >= 6) return;
    HapticFeedback.selectionClick();
    setState(() => _pin += value);
  }

  void _deletePin() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;

          final screenWidth = size.width;
          final screenHeight = size.height;

          final isUltraWide = screenWidth >= 1600;

          final isDesktop = screenWidth >= 1200;

          final isLaptop = screenWidth >= 992 && screenWidth < 1200;

          final isTablet = screenWidth >= 700 && screenWidth < 992;

          final isMobile = screenWidth < 700;

          final horizontalPadding = isMobile
              ? 14.0
              : isTablet
                  ? 20.0
                  : isLaptop
                      ? 24.0
                      : 32.0;

          final contentMaxWidth = isUltraWide
              ? 1600.0
              : isDesktop
                  ? 1400.0
                  : isLaptop
                      ? 1180.0
                      : double.infinity;

          final showLeftPanel = screenWidth >= 1200 && screenHeight >= 760;

          return Stack(
            children: [
              _LoginBackdrop(
                animation: _ambientController,
                isMobile: isMobile,
                isTablet: isTablet,
              ),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: contentMaxWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            isMobile ? 18 : 28,
                            horizontalPadding,
                            22,
                          ),
                          child: Column(
                            children: [
                              _TopHeader(isMobile: isMobile),
                              SizedBox(height: isDesktop ? 74 : 38),
                              if (isDesktop || isLaptop)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _LeftShowcase(
                                        animation: _ambientController,
                                        showLeftPanel: showLeftPanel,
                                        screenHeight: screenHeight,
                                      ),
                                    ),
                                    SizedBox(width: isLaptop ? 28 : 52),
                                    _LoginCard(
                                      formKey: _formKey,
                                      tabController: _tabController,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      pin: _pin,
                                      pinError: _pinError,
                                      rememberDevice: _rememberDevice,
                                      rememberPin: _rememberPin,
                                      onRememberDeviceChanged: (value) {
                                        setState(() => _rememberDevice = value);
                                      },
                                      onRememberPinChanged: (value) {
                                        setState(() => _rememberPin = value);
                                      },
                                      onPasswordSubmit: _submitPassword,
                                      onPinKey: _onPinKey,
                                      onPinDelete: _deletePin,
                                      onPinSubmit: _submitPin,
                                      isMobile: false,
                                      isTablet: isTablet,
                                      isLaptop: isLaptop,
                                    ),
                                  ],
                                )
                              else
                                Center(
                                  child: _LoginCard(
                                    formKey: _formKey,
                                    tabController: _tabController,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    pin: _pin,
                                    pinError: _pinError,
                                    rememberDevice: _rememberDevice,
                                    rememberPin: _rememberPin,
                                    onRememberDeviceChanged: (value) {
                                      setState(() => _rememberDevice = value);
                                    },
                                    onRememberPinChanged: (value) {
                                      setState(() => _rememberPin = value);
                                    },
                                    onPasswordSubmit: _submitPassword,
                                    onPinKey: _onPinKey,
                                    onPinDelete: _deletePin,
                                    onPinSubmit: _submitPin,
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                    isLaptop: isLaptop,
                                  ),
                                ),
                              SizedBox(height: isDesktop ? 56 : 28),
                              _FeatureCards(
                                isMobile: isMobile,
                                isTablet: isTablet,
                                isLaptop: isLaptop,
                              ),
                              const SizedBox(height: 26),
                              const _LoginFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  final Animation<double> animation;
  final bool isMobile;
  final bool isTablet;

  const _LoginBackdrop({
    required this.animation,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF050816),
                Color(0xFF0B1120),
                Color(0xFF111827),
                Color(0xFF111D4D),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -150 + math.sin(animation.value * math.pi * 2) * 18,
                right: -180,
                child: _GlowOrb(
                  size: isMobile ? 320 : isTablet ? 420 : 560,
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(isMobile ? 0.35 : 0.60),
                    const Color(0xFF6366F1).withOpacity(isMobile ? 0.12 : 0.24),
                    Colors.transparent,
                  ],
                  blur: isMobile ? 12.0 : isTablet ? 18.0 : 24.0,
                ),
              ),
              Positioned(
                bottom: -180,
                left: -180 + math.cos(animation.value * math.pi * 2) * 18,
                child: _GlowOrb(
                  size: isMobile ? 300 : isTablet ? 400 : 520,
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(isMobile ? 0.25 : 0.42),
                    const Color(0xFF312E81).withOpacity(isMobile ? 0.10 : 0.18),
                    Colors.transparent,
                  ],
                  blur: isMobile ? 12.0 : isTablet ? 18.0 : 24.0,
                ),
              ),
              CustomPaint(
                painter: _ParticlePainter(
                  animation.value,
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double blur;

  const _GlowOrb({
    required this.size,
    required this.colors,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final bool isMobile;
  final bool isTablet;

  _ParticlePainter(
    this.progress, {
    required this.isMobile,
    required this.isTablet,
  });

  static const _particles = [
    Offset(0.18, 0.16),
    Offset(0.28, 0.28),
    Offset(0.41, 0.17),
    Offset(0.63, 0.14),
    Offset(0.77, 0.24),
    Offset(0.92, 0.18),
    Offset(0.13, 0.44),
    Offset(0.30, 0.58),
    Offset(0.54, 0.42),
    Offset(0.83, 0.52),
    Offset(0.16, 0.76),
    Offset(0.44, 0.82),
    Offset(0.68, 0.74),
    Offset(0.91, 0.78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.00),
          const Color(0xFF3B82F6).withOpacity(0.20),
          Colors.white.withOpacity(0.00),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final maxRays = isMobile ? 2 : isTablet ? 3 : 5;
    for (var index = 0; index < maxRays; index++) {
      final dy = (index * 170.0 + progress * 90) % size.height;
      canvas.drawLine(
        Offset(size.width * 0.73, dy),
        Offset(size.width * 0.85, dy - 90),
        rayPaint,
      );
    }

    final maxParticles = isMobile
        ? 6
        : isTablet
            ? 10
            : _particles.length;

    for (var i = 0; i < maxParticles; i++) {
      final base = _particles[i];
      final phase = progress * math.pi * 2 + i;
      final x = base.dx * size.width + math.sin(phase) * 12;
      final y = base.dy * size.height + math.cos(phase * 0.8) * 14;
      final radius = 1.8 + (i % 4) * 1.1;
      final paint = Paint()
        ..color = [
          const Color(0xFF3B82F6),
          const Color(0xFF6366F1),
          const Color(0xFF8B5CF6),
        ][i % 3]
            .withOpacity(0.22 + (math.sin(phase) + 1) * 0.12);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    if (!isMobile) {
      final hexPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF60A5FA).withOpacity(0.12);
      _drawHexagon(canvas, Offset(size.width * 0.92, size.height * 0.34), 48,
          hexPaint, progress * math.pi);
      if (!isTablet) {
        _drawHexagon(canvas, Offset(size.width * 0.24, size.height * 0.55), 26,
            hexPaint, -progress * math.pi * 1.3);
        _drawHexagon(canvas, Offset(size.width * 0.54, size.height * 0.88), 34,
            hexPaint, progress * math.pi * 1.8);
      }
    }
  }

  void _drawHexagon(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    double rotation,
  ) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = rotation + (math.pi / 3 * i);
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isMobile != isMobile ||
        oldDelegate.isTablet != isTablet;
  }
}

class _TopHeader extends StatelessWidget {
  final bool isMobile;

  const _TopHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _BrandHeader(isCompact: isMobile)),
        const SizedBox(width: 16),
        _TopRightActions(isCompact: isMobile),
      ],
    ).animate().fadeIn(duration: 520.ms).slideY(begin: -0.08, end: 0);
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isCompact;

  const _BrandHeader({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LogoMark(size: isCompact ? 48 : 72),
        SizedBox(width: isCompact ? 12 : 18),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRINTONEX ERP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 19 : 31,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: isCompact ? 5 : 9),
              Text(
                'Enterprise Solution',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.74),
                  fontSize: isCompact ? 12 : 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;

  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF7AB6),
            Color(0xFF8B5CF6),
            Color(0xFF38BDF8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.38),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.52,
          height: size * 0.52,
          decoration: BoxDecoration(
            color: const Color(0xFF050816),
            borderRadius: BorderRadius.circular(size * 0.12),
          ),
        ),
      ),
    );
  }
}

class _TopRightActions extends StatelessWidget {
  final bool isCompact;

  const _TopRightActions({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<AppThemeController>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionCircle(
                icon: Icons.light_mode_outlined,
                isActive: !themeController.isDarkMode,
                onTap: themeController.toggleTheme,
              ),
              const SizedBox(width: 6),
              _ActionCircle(
                icon: Icons.dark_mode_rounded,
                isActive: themeController.isDarkMode,
                onTap: themeController.toggleTheme,
              ),
              if (!isCompact) ...[
                const SizedBox(width: 8),
                Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withOpacity(0.10)),
                const SizedBox(width: 8),
                const _LanguagePill(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionCircle({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ActionCircle> createState() => _ActionCircleState();
}

class _ActionCircleState extends State<_ActionCircle> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.06 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive
                  ? Colors.white.withOpacity(0.13)
                  : Colors.transparent,
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.24),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Icon(widget.icon, color: Colors.white, size: 23),
          ),
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.language_rounded, color: Colors.white, size: 23),
          const SizedBox(width: 10),
          const Text(
            'English',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.78)),
        ],
      ),
    );
  }
}

class _LeftShowcase extends StatelessWidget {
  final Animation<double> animation;
  final bool showLeftPanel;
  final double screenHeight;

  const _LeftShowcase({
    required this.animation,
    required this.showLeftPanel,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (!showLeftPanel) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _SecurityStory(),
      );
    }

    return SizedBox(
      height: math.min(screenHeight * 0.72, 680),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -44,
            top: 92,
            child: _AnalyticsMonitor(animation: animation),
          ),
          Positioned(
            left: -14,
            top: 310,
            child: _PosTerminal(animation: animation),
          ),
          Positioned(
            left: -48,
            top: 470,
            child: _CashDrawer(),
          ),
          Positioned(
            left: 64,
            bottom: 82,
            child: _ReceiptPrinter(animation: animation),
          ),
          Positioned(
            left: 0,
            bottom: 48,
            child: _SecurityStory(),
          ),
          Positioned(
            right: 110,
            top: 318,
            child: _FloatingCube(
              size: 54,
              color: const Color(0xFF8B5CF6),
              animation: animation,
              phase: 0.2,
            ),
          ),
          Positioned(
            right: 18,
            top: 430,
            child: _FloatingCube(
              size: 40,
              color: const Color(0xFF3B82F6),
              animation: animation,
              phase: 1.2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 140.ms, duration: 720.ms).slideX(begin: -0.08);
  }
}

class _AnalyticsMonitor extends StatelessWidget {
  final Animation<double> animation;

  const _AnalyticsMonitor({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = math.sin(animation.value * math.pi * 2) * 10;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(-0.24)
          ..rotateZ(0.10),
        child: Container(
          width: 410,
          height: 210,
          padding: const EdgeInsets.all(18),
          decoration: _holoDecoration(28),
          child: Row(
            children: [
              Expanded(
                child: _MiniChartCard(
                  title: 'Sales Overview',
                  amount: '\u20B9 24,80,000',
                  delta: '+18.6%',
                  icon: Icons.show_chart_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _BarChartMock(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChartCard extends StatelessWidget {
  final String title;
  final String amount;
  final String delta;
  final IconData icon;

  const _MiniChartCard({
    required this.title,
    required this.amount,
    required this.delta,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.66),
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            delta,
            style: const TextStyle(
              color: Color(0xFF34D399),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 28, child: CustomPaint(painter: _TinyLinePainter())),
        ],
      ),
    );
  }
}

class _BarChartMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final heights = [42.0, 66.0, 86.0, 112.0, 130.0, 158.0];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final height in heights)
            Container(
              width: 16,
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF60A5FA), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}

class _TinyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.78),
      Offset(size.width * 0.16, size.height * 0.62),
      Offset(size.width * 0.28, size.height * 0.70),
      Offset(size.width * 0.42, size.height * 0.38),
      Offset(size.width * 0.55, size.height * 0.52),
      Offset(size.width * 0.70, size.height * 0.22),
      Offset(size.width, size.height * 0.05),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF8B5CF6)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PosTerminal extends StatelessWidget {
  final Animation<double> animation;

  const _PosTerminal({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, math.cos(animation.value * math.pi * 2) * 8),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(-0.28)
              ..rotateX(0.20),
            child: Container(
              width: 210,
              height: 178,
              padding: const EdgeInsets.all(18),
              decoration: _holoDecoration(32),
              child: Column(
                children: [
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const Center(
                      child: Icon(Icons.credit_card_rounded,
                          color: Color(0xFF93C5FD), size: 28),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        for (var i = 0; i < 9; i++)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6).withOpacity(0.82),
                                  const Color(0xFF8B5CF6).withOpacity(0.72),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CashDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.05,
      child: Container(
        width: 180,
        height: 110,
        decoration: _holoDecoration(24),
        child: Center(
          child: Container(
            width: 72,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.payments_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ReceiptPrinter extends StatelessWidget {
  final Animation<double> animation;

  const _ReceiptPrinter({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(animation.value * math.pi * 2 + 1.4) * 7),
          child: child,
        );
      },
      child: Transform.rotate(
        angle: -0.06,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: -54,
              child: Container(
                width: 82,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                        width: 38, height: 4, color: const Color(0xFF94A3B8)),
                    const SizedBox(height: 8),
                    Container(
                        width: 48, height: 4, color: const Color(0xFFCBD5E1)),
                  ],
                ),
              ),
            ),
            Container(
              width: 160,
              height: 102,
              decoration: _holoDecoration(22),
              child: const Center(
                child: Icon(Icons.receipt_long_rounded,
                    color: Color(0xFF93C5FD), size: 34),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCube extends StatelessWidget {
  final double size;
  final Color color;
  final Animation<double> animation;
  final double phase;

  const _FloatingCube({
    required this.size,
    required this.color,
    required this.animation,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value * math.pi * 2 + phase;
        return Transform.translate(
          offset: Offset(math.sin(t) * 8, math.cos(t) * 12),
          child: Transform.rotate(
            angle: 0.65 + math.sin(t) * 0.12,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.86),
                    const Color(0xFF38BDF8).withOpacity(0.48),
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.18),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.34),
                    blurRadius: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SecurityStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: const Icon(Icons.security_rounded,
                color: Color(0xFF60A5FA), size: 32),
          ),
          const SizedBox(height: 58),
          const Text(
            'Secure. Smart. Simple.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manage your business,\nanytime, anywhere.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _holoDecoration(double radius) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.12),
        const Color(0xFF312E81).withOpacity(0.18),
        const Color(0xFF050816).withOpacity(0.44),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.36)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF3B82F6).withOpacity(0.20),
        blurRadius: 28,
        offset: const Offset(0, 18),
      ),
    ],
  );
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TabController tabController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String pin;
  final bool pinError;
  final bool rememberDevice;
  final bool rememberPin;
  final ValueChanged<bool> onRememberDeviceChanged;
  final ValueChanged<bool> onRememberPinChanged;
  final VoidCallback onPasswordSubmit;
  final ValueChanged<String> onPinKey;
  final VoidCallback onPinDelete;
  final VoidCallback onPinSubmit;
  final bool isMobile;
  final bool isTablet;
  final bool isLaptop;

  const _LoginCard({
    required this.formKey,
    required this.tabController,
    required this.emailController,
    required this.passwordController,
    required this.pin,
    required this.pinError,
    required this.rememberDevice,
    required this.rememberPin,
    required this.onRememberDeviceChanged,
    required this.onRememberPinChanged,
    required this.onPasswordSubmit,
    required this.onPinKey,
    required this.onPinDelete,
    required this.onPinSubmit,
    required this.isMobile,
    required this.isTablet,
    required this.isLaptop,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isMobile
        ? double.infinity
        : isTablet
            ? 500.0
            : isLaptop
                ? 520.0
                : 580.0;
    final cardPadding = isMobile
        ? 18.0
        : isTablet
            ? 22.0
            : 32.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cardWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.13),
                  const Color(0xFF111827).withOpacity(0.46),
                  const Color(0xFF050816).withOpacity(0.52),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.32)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.30),
                  blurRadius: 46,
                  offset: const Offset(18, -14),
                ),
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.22),
                  blurRadius: 46,
                  offset: const Offset(-20, 22),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.42),
                  blurRadius: 38,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome Back 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 30 : 36,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to continue to Printonex ERP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: isMobile
                      ? 18
                      : isTablet
                          ? 24
                          : isLaptop
                              ? 28
                              : 42,
                ),
                _LoginMethodTabs(
                  controller: tabController,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: isMobile
                      ? 460
                      : isTablet
                          ? 430
                          : 400,
                  child: TabBarView(
                    controller: tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _PasswordTab(
                        formKey: formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                        rememberDevice: rememberDevice,
                        onRememberChanged: onRememberDeviceChanged,
                        onSubmit: onPasswordSubmit,
                      ),
                      _PinTab(
                        pin: pin,
                        hasError: pinError,
                        rememberPin: rememberPin,
                        onRememberChanged: onRememberPinChanged,
                        onKey: onPinKey,
                        onDelete: onPinDelete,
                        onSubmit: onPinSubmit,
                      ),
                      const _FingerprintTab(),
                      const _QrLoginTab(),
                    ],
                  ),
                ),
                const _CardDivider(),
                const SizedBox(height: 18),
                _GlassOutlineButton(
                  icon: Icons.account_balance_rounded,
                  label: 'Login as Another Store',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.74),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Contact Administrator',
                          style: TextStyle(
                            color: Color(0xFF60A5FA),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 220.ms, duration: 700.ms).slideY(begin: 0.06);
  }
}

class _LoginMethodTabs extends StatelessWidget {
  final TabController controller;
  final bool isMobile;

  const _LoginMethodTabs({
    required this.controller,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _MethodTabData(Icons.lock_outline_rounded, 'Password'),
      _MethodTabData(Icons.dialpad_rounded, 'PIN'),
      _MethodTabData(Icons.fingerprint_rounded, 'Fingerprint'),
      _MethodTabData(Icons.qr_code_scanner_rounded, 'QR Login'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: TabBar(
            controller: controller,
            isScrollable: isMobile,
            tabAlignment: isMobile ? TabAlignment.start : TabAlignment.fill,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF60A5FA).withOpacity(0.46),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.72),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            tabs: [
              for (final tab in tabs)
                Tab(
                  height: 56,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: isMobile ? 112 : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tab.icon, size: 20),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTabData {
  final IconData icon;
  final String label;

  const _MethodTabData(this.icon, this.label);
}

class _PasswordTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberDevice;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;

  const _PasswordTab({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberDevice,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GlassTextField(
            controller: emailController,
            label: 'Email Address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email or username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Obx(
            () => _GlassTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: !auth.isPasswordVisible.value,
              suffixIcon: auth.isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () {
                auth.isPasswordVisible.value = !auth.isPasswordVisible.value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                return null;
              },
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF60A5FA),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _PremiumCheckbox(
                value: rememberDevice,
                onChanged: onRememberChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Remember this device',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.info_outline_rounded,
                  color: Colors.white.withOpacity(0.38), size: 19),
              const Spacer(),
              const _SecureLoginBadge(),
            ],
          ),
          const SizedBox(height: 28),
          _GradientLoginButton(label: 'Sign In', onTap: onSubmit),
        ],
      ),
    );
  }
}

class _GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<_GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<_GlassTextField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.94),
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(focused ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focused
                  ? const Color(0xFF60A5FA).withOpacity(0.62)
                  : Colors.white.withOpacity(0.12),
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.20),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onFieldSubmitted: widget.onSubmitted,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: const Color(0xFF60A5FA),
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
              prefixIcon: Icon(widget.icon,
                  color: Colors.white.withOpacity(0.70), size: 23),
              suffixIcon: widget.suffixIcon == null
                  ? null
                  : IconButton(
                      onPressed: widget.onSuffixTap,
                      icon: Icon(widget.suffixIcon,
                          color: Colors.white.withOpacity(0.78)),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PinTab extends StatelessWidget {
  final String pin;
  final bool hasError;
  final bool rememberPin;
  final ValueChanged<bool> onRememberChanged;
  final ValueChanged<String> onKey;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  const _PinTab({
    required this.pin,
    required this.hasError,
    required this.rememberPin,
    required this.onRememberChanged,
    required this.onKey,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: hasError ? const Offset(0.025, 0) : Offset.zero,
      duration: const Duration(milliseconds: 80),
      curve: Curves.elasticIn,
      child: Column(
        children: [
          Text(
            'Enter your 4  digit secure PIN',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < 4; index++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 42,
                  height: 48,
                  decoration: BoxDecoration(
                    color: index < pin.length
                        ? const Color(0xFF6366F1).withOpacity(0.42)
                        : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasError
                          ? AppTheme.dangerColor
                          : index < pin.length
                              ? const Color(0xFF60A5FA).withOpacity(0.72)
                              : Colors.white.withOpacity(0.14),
                    ),
                    boxShadow: index < pin.length
                        ? [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.28),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: index < pin.length ? 10 : 0,
                      height: index < pin.length ? 10 : 0,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _PinKeypad(
              onKey: onKey,
              onDelete: onDelete,
              onSubmit: onSubmit,
            ),
          ),
          Row(
            children: [
              _PremiumCheckbox(
                  value: rememberPin, onChanged: onRememberChanged),
              const SizedBox(width: 12),
              Text(
                'Remember PIN',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.88),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.face_rounded, size: 18),
                label: const Text('Face ID'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF60A5FA),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;

  const _PinKeypad({
    required this.onKey,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = math.min(58.0, constraints.maxHeight / 4.2);

        return Column(
          children: [
            for (var row = 0; row < 3; row++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var col = 0; col < 3; col++)
                    _PinKeyButton(
                      size: buttonSize,
                      label: keys[row * 3 + col],
                      onTap: () => onKey(keys[row * 3 + col]),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PinIconButton(
                  size: buttonSize,
                  icon: Icons.backspace_outlined,
                  onTap: onDelete,
                ),
                _PinKeyButton(
                  size: buttonSize,
                  label: '0',
                  onTap: () => onKey('0'),
                ),
                _PinIconButton(
                  size: buttonSize,
                  icon: Icons.check_rounded,
                  onTap: onSubmit,
                  accent: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  final double size;
  final String label;
  final VoidCallback onTap;

  const _PinKeyButton({
    required this.size,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PinButtonShell(
      size: size,
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PinIconButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  const _PinIconButton({
    required this.size,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return _PinButtonShell(
      size: size,
      onTap: onTap,
      accent: accent,
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _PinButtonShell extends StatefulWidget {
  final double size;
  final Widget child;
  final VoidCallback onTap;
  final bool accent;

  const _PinButtonShell({
    required this.size,
    required this.child,
    required this.onTap,
    this.accent = false,
  });

  @override
  State<_PinButtonShell> createState() => _PinButtonShellState();
}

class _PinButtonShellState extends State<_PinButtonShell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.05 : 1,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            width: widget.size,
            height: widget.size,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.accent
                  ? const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                    )
                  : null,
              color: widget.accent
                  ? null
                  : Colors.white.withOpacity(_hovering ? 0.14 : 0.08),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _FingerprintTab extends StatelessWidget {
  const _FingerprintTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 170,
              height: 170,
              child: Lottie.asset(
                'assets/lottie/sync_pulse.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.34),
                    const Color(0xFF8B5CF6).withOpacity(0.18),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: const Icon(Icons.fingerprint_rounded,
                  color: Colors.white, size: 72),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Touch fingerprint sensor to login',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Device support detection is ready. Use password or PIN as fallback.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        _GlassOutlineButton(
          icon: Icons.lock_reset_rounded,
          label: 'Use Password Instead',
          onTap: () {},
        ),
      ],
    );
  }
}

class _QrLoginTab extends StatelessWidget {
  const _QrLoginTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _QrScannerFrame(),
        const SizedBox(height: 26),
        const Text(
          'Scan QR from desktop to login',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Open Printonex ERP on your trusted device and scan the secure pairing code.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.68),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _QrScannerFrame extends StatefulWidget {
  const _QrScannerFrame();

  @override
  State<_QrScannerFrame> createState() => _QrScannerFrameState();
}

class _QrScannerFrameState extends State<_QrScannerFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.qr_code_2_rounded,
                color: Colors.white.withOpacity(0.80), size: 118),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _QrCornerPainter(),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Positioned(
                left: 22,
                right: 22,
                top: 28 + (_controller.value * 126),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF22D3EE),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22D3EE).withOpacity(0.62),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QrCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22D3EE)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const inset = 20.0;
    const length = 34.0;

    canvas.drawLine(
        const Offset(inset, inset), const Offset(inset + length, inset), paint);
    canvas.drawLine(
        const Offset(inset, inset), const Offset(inset, inset + length), paint);
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset - length, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset, inset + length), paint);
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset + length, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset, size.height - inset - length), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - length, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset, size.height - inset - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PremiumCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumCheckbox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
                )
              : null,
          color: value ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? const Color(0xFF60A5FA)
                : Colors.white.withOpacity(0.18),
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.36),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: value
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

class _SecureLoginBadge extends StatelessWidget {
  const _SecureLoginBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.verified_user_outlined, color: Color(0xFF22D3EE), size: 20),
        SizedBox(width: 8),
        Text(
          'Secure Login',
          style: TextStyle(
            color: Color(0xFF22D3EE),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GradientLoginButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientLoginButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_GradientLoginButton> createState() => _GradientLoginButtonState();
}

class _GradientLoginButtonState extends State<_GradientLoginButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.012 : 1,
        duration: const Duration(milliseconds: 180),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9333EA),
                  Color(0xFF3B82F6),
                  Color(0xFF0EA5E9)
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6)
                      .withOpacity(_hovering ? 0.45 : 0.26),
                  blurRadius: _hovering ? 28 : 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Obx(
                () => auth.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassOutlineButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassOutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_GlassOutlineButton> createState() => _GlassOutlineButtonState();
}

class _GlassOutlineButtonState extends State<_GlassOutlineButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hovering ? 1.01 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_hovering ? 0.10 : 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovering
                    ? const Color(0xFF60A5FA).withOpacity(0.52)
                    : Colors.white.withOpacity(0.24),
              ),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.18),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 23),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(height: 1, color: Colors.white.withOpacity(0.10))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(
            child: Container(height: 1, color: Colors.white.withOpacity(0.10))),
      ],
    );
  }
}

class _FeatureCards extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isLaptop;

  const _FeatureCards({
    required this.isMobile,
    required this.isTablet,
    required this.isLaptop,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureData(Icons.verified_user_rounded, 'Bank-Level Security',
          '256-bit encrypted', const Color(0xFF34D399)),
      _FeatureData(Icons.sync_rounded, 'Auto Sync', 'Real-time data',
          const Color(0xFF60A5FA)),
      _FeatureData(Icons.cloud_done_rounded, 'Works Offline',
          'Sync when online', const Color(0xFF34D399)),
      _FeatureData(Icons.backup_rounded, 'Daily Backup', 'Your data is safe',
          const Color(0xFF8B5CF6)),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1080),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = isMobile
                    ? 1
                    : isTablet
                        ? 2
                        : isLaptop
                            ? 2
                            : 4;
                final width =
                    (constraints.maxWidth - ((columns - 1) * 16)) / columns;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final feature in features)
                      SizedBox(
                        width: width,
                        child: _FeatureTile(feature: feature),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 340.ms, duration: 680.ms).slideY(begin: 0.08);
  }
}

class _FeatureTile extends StatefulWidget {
  final _FeatureData feature;

  const _FeatureTile({required this.feature});

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final feature = widget.feature;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_hovering ? 0.08 : 0.02),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.16),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: feature.color.withOpacity(_hovering ? 0.35 : 0.18),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Icon(feature.icon, color: feature.color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              feature.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureData(this.icon, this.title, this.subtitle, this.color);
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1080),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '© 2025 Printonex Technologies Pvt. Ltd. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.46),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'v2.5.1',
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
