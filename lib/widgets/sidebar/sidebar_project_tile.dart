import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialogs/project_dialog.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../common/confirm_dialog.dart';
import '../common/glow_dot.dart';
import 'sidebar_tile.dart';

class SidebarProjectTile extends StatelessWidget {
  const SidebarProjectTile({
    super.key,
    required this.project,
    required this.selected,
    required this.onTap,
    required this.collapsed,
  });

  final Project project;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SidebarTile(
      selected: selected,
      onTap: onTap,
      accent: project.color,
      collapsed: collapsed,
      leading: GlowDot(
        color: project.color,
        size: 10,
        glow: selected,
        glowRadius: 10,
      ),
      label: project.name,
      // Actions are always visible (no hover required) on the expanded tile.
      trailing: collapsed ? null : _ProjectMenu(project: project),
    );
  }
}

class _ProjectMenu extends StatelessWidget {
  const _ProjectMenu({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'commonActions'.tr(),
      color: AppColors.surfaceElevated,
      padding: EdgeInsets.zero,
      iconSize: 16,
      // Make the trigger compact so it doesn't eat the tile width on phones.
      style: IconButton.styleFrom(
        minimumSize: const Size(28, 28),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(Icons.more_horiz,
          size: 16, color: AppColors.textMuted),
      onSelected: (v) async {
        if (v == 'edit') {
          await showProjectDialog(context, existing: project);
        } else if (v == 'delete') {
          final ok = await showConfirmDialog(
            context,
            title: 'confirmDeleteProjectTitle'
                .tr(namedArgs: {'name': project.name}),
            body: 'confirmDeleteProjectBody'.tr(),
          );
          if (ok && context.mounted) {
            await context.read<AppState>().deleteProject(project.id);
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'edit', child: Text('commonEdit'.tr())),
        PopupMenuItem(value: 'delete', child: Text('commonDelete'.tr())),
      ],
    );
  }
}
