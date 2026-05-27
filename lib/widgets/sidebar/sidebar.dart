import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../dialogs/env_dialog.dart';
import '../../dialogs/project_dialog.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../common/confirm_dialog.dart';
import 'sidebar_all_projects_tile.dart';
import 'sidebar_brand.dart';
import 'sidebar_env_tile.dart';
import 'sidebar_footer.dart';
import 'sidebar_project_tile.dart';
import 'sidebar_section_header.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    this.collapsed = false,
    this.canCollapse = true,
    this.onProjectTap,
    this.onEnvTap,
  });

  final bool collapsed;
  final bool canCollapse;
  final ValueChanged<Project?>? onProjectTap;
  final ValueChanged<EnvDef?>? onEnvTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          SidebarBrand(collapsed: collapsed),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                SidebarSectionHeader(
                  label: 'sidebarProjects'.tr(),
                  collapsed: collapsed,
                  trailing: SidebarAddButton(
                    tooltip: 'sidebarNewProject'.tr(),
                    onTap: () => showProjectDialog(context),
                  ),
                ),
                SidebarAllProjectsTile(
                  selected: state.selectedProjectId == null,
                  collapsed: collapsed,
                  onTap: () {
                    state.selectProject(null);
                    onProjectTap?.call(null);
                  },
                ),
                ...state.projects.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  return SidebarProjectTile(
                    project: p,
                    selected: state.selectedProjectId == p.id,
                    collapsed: collapsed,
                    onTap: () {
                      state.selectProject(p.id);
                      onProjectTap?.call(p);
                    },
                  )
                      .animate()
                      .fadeIn(delay: (40 * i).ms, duration: 220.ms)
                      .slideX(begin: -0.05, end: 0, duration: 220.ms);
                }),
                const SizedBox(height: 16),
                SidebarSectionHeader(
                  label: 'sidebarEnvironments'.tr(),
                  collapsed: collapsed,
                  trailing: SidebarAddButton(
                    tooltip: 'sidebarNewEnvironment'.tr(),
                    onTap: () => showEnvDialog(context),
                  ),
                ),
                SidebarEnvTile(
                  label: 'commonAll'.tr(),
                  color: AppColors.textMuted,
                  selected: state.selectedEnvId == null,
                  collapsed: collapsed,
                  onTap: () {
                    state.selectEnv(null);
                    onEnvTap?.call(null);
                  },
                ),
                ...state.envs.map((e) {
                  return SidebarEnvTile(
                    label: e.name,
                    color: e.color,
                    selected: state.selectedEnvId == e.id,
                    custom: e.isCustom,
                    collapsed: collapsed,
                    onTap: () {
                      state.selectEnv(e.id);
                      onEnvTap?.call(e);
                    },
                    onDelete: e.isCustom
                        ? () async {
                            final ok = await showConfirmDialog(
                              context,
                              title: 'confirmDeleteEnvTitle'
                                  .tr(namedArgs: {'name': e.name}),
                              body: 'confirmDeleteEnvBody'.tr(),
                            );
                            if (ok) await state.deleteEnv(e.id);
                          }
                        : null,
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const Divider(height: 1),
          SidebarFooter(collapsed: collapsed, canCollapse: canCollapse),
        ],
      ),
    );
  }
}
