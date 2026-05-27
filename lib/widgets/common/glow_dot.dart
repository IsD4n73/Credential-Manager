import 'package:flutter/material.dart';

/// Colored circular dot with optional neon glow.
class GlowDot extends StatelessWidget {
  const GlowDot({
    super.key,
    required this.color,
    this.size = 8,
    this.glow = true,
    this.glowRadius = 8,
  });

  final Color color;
  final double size;
  final bool glow;
  final double glowRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: glowRadius,
                ),
              ]
            : null,
      ),
    );
  }
}
