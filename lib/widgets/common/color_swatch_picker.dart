import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A row/wrap of selectable colour circles. The selected one gets a white
/// ring and a soft glow. Used in project and env creation dialogs.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.colors = AppColors.projectPalette,
    this.swatchSize = 32,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Color> colors;
  final double swatchSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(colors.length, (i) {
        final c = colors[i];
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: swatchSize,
            height: swatchSize,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: c.withValues(alpha: selected ? 0.7 : 0.0),
                  blurRadius: 14,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
