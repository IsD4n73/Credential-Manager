import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common/env_color_bar.dart';
import 'sidebar_tile.dart';

class SidebarEnvTile extends StatefulWidget {
  const SidebarEnvTile({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.collapsed,
    this.custom = false,
    this.onDelete,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool custom;
  final bool collapsed;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  State<SidebarEnvTile> createState() => _SidebarEnvTileState();
}

class _SidebarEnvTileState extends State<SidebarEnvTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: SidebarTile(
        selected: widget.selected,
        onTap: widget.onTap,
        accent: widget.color,
        collapsed: widget.collapsed,
        leading: EnvColorBar(color: widget.color, glow: widget.selected),
        label: widget.label,
        mono: true,
        trailing: !widget.collapsed &&
                widget.custom &&
                _hover &&
                widget.onDelete != null
            ? InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close,
                      size: 14, color: AppColors.textMuted),
                ),
              )
            : null,
      ),
    );
  }
}
