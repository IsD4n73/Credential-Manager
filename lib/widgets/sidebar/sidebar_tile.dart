import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Base tile used for All-projects, project, env and all-env rows in the
/// sidebar. Handles selection highlight, hover background, collapsed (icon-
/// only) mode and an optional trailing widget.
class SidebarTile extends StatefulWidget {
  const SidebarTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.label,
    required this.accent,
    required this.collapsed,
    this.trailing,
    this.mono = false,
  });

  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;
  final Widget leading;
  final String label;
  final Color accent;
  final Widget? trailing;
  final bool mono;

  @override
  State<SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<SidebarTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tile = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: widget.collapsed
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
              : const EdgeInsets.fromLTRB(10, 2, 10, 2),
          padding: widget.collapsed
              ? const EdgeInsets.symmetric(vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.accent.withValues(alpha: 0.12)
                : _hover
                    ? AppColors.surfaceAlt
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.selected
                  ? widget.accent.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.collapsed
              ? Center(child: widget.leading)
              : Row(
                  children: [
                    SizedBox(width: 18, child: Center(child: widget.leading)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: widget.mono
                            ? AppTheme.mono(
                                size: 13,
                                color: widget.selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                weight: widget.selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )
                            : TextStyle(
                                fontSize: 13.5,
                                color: widget.selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: widget.selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                      ),
                    ),
                    ?widget.trailing,
                  ],
                ),
        ),
      ),
    );

    if (widget.collapsed) {
      return Tooltip(
        message: widget.label,
        waitDuration: const Duration(milliseconds: 350),
        child: tile,
      );
    }
    return tile;
  }
}
