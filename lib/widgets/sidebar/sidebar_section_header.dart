import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SidebarSectionHeader extends StatelessWidget {
  const SidebarSectionHeader({
    super.key,
    required this.label,
    required this.collapsed,
    this.trailing,
  });

  final String label;
  final Widget? trailing;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
        child: Center(child: trailing ?? const SizedBox.shrink()),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 12, 6),
      child: Row(
        children: [
          // Flexible so the label collapses with ellipsis during the
          // sidebar's collapse/expand width animation, instead of overflowing.
          Flexible(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppTheme.mono(
                size: 11,
                color: AppColors.textMuted,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 1.6),
            ),
          ),
          const SizedBox(width: 8),
          ?trailing,
        ],
      ),
    );
  }
}

class SidebarAddButton extends StatelessWidget {
  const SidebarAddButton({
    super.key,
    required this.tooltip,
    required this.onTap,
  });
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.add, size: 16, color: AppColors.accentCyan),
        ),
      ),
    );
  }
}
