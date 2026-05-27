import 'package:flutter/material.dart';

/// Small horizontal coloured pill used to represent an environment.
class EnvColorBar extends StatelessWidget {
  const EnvColorBar({
    super.key,
    required this.color,
    this.width = 14,
    this.height = 6,
    this.glow = false,
  });

  final Color color;
  final double width;
  final double height;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.7),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}
