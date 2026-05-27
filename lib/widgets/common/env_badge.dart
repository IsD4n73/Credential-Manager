import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Uppercase environment label inside a coloured outlined chip.
class EnvBadge extends StatelessWidget {
  const EnvBadge({
    super.key,
    required this.label,
    required this.color,
    this.glow = false,
  });

  final String label;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTheme.mono(
          size: 10,
          color: color,
          weight: FontWeight.w800,
        ).copyWith(letterSpacing: 1.2),
      ),
    );
  }
}
