import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';

/// Brand mark = gradient cyan→magenta badge with the "1" glyph (or a custom
/// child). Used in the sidebar header and the lock screen.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 36,
    this.circular = false,
    this.child,
    this.pulse = true,
  });

  final double size;
  final bool circular;
  final Widget? child;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: circular ? null : BorderRadius.circular(size * 0.28),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        gradient: const LinearGradient(
          colors: [AppColors.accentCyan, AppColors.accentMagenta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.35),
            blurRadius: size * 0.6,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child ??
          Text(
            '1',
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF001318),
              height: 1,
            ),
          ),
    );
    if (!pulse) return inner;
    return inner
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
            begin: 1, end: 1.05, duration: 1800.ms, curve: Curves.easeInOut);
  }
}
