import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? shadows;
  final BoxConstraints? constraints;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.blur = 18,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.gradient,
    this.border,
    this.shadows,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            color: color ??
                (isDark
                    ? const Color(0xFF1E293B).withOpacity(0.72)
                    : Colors.white.withOpacity(0.72)),
            gradient: gradient,
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.10)
                      : const Color(0xFFCBD5E1).withOpacity(0.82),
                ),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.26 : 0.08),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}
