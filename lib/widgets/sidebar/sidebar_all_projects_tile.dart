import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'sidebar_tile.dart';

class SidebarAllProjectsTile extends StatelessWidget {
  const SidebarAllProjectsTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.collapsed,
  });
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SidebarTile(
      selected: selected,
      onTap: onTap,
      collapsed: collapsed,
      leading: const Icon(Icons.all_inbox_outlined,
          size: 16, color: AppColors.textSecondary),
      label: 'sidebarAllProjects'.tr(),
      accent: AppColors.accentCyan,
    );
  }
}
