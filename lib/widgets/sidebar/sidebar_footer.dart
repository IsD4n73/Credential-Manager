import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../dialogs/settings_sheet.dart';
import '../../state/app_state.dart';
import '../../state/ui_prefs.dart';
import '../../theme/app_theme.dart';

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({
    super.key,
    required this.collapsed,
    required this.canCollapse,
  });

  final bool collapsed;
  final bool canCollapse;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final prefs = context.watch<UiPrefs>();
    final total = state.credentials.length;

    final collapseBtn = canCollapse
        ? IconButton(
            tooltip:
                collapsed ? 'sidebarExpand'.tr() : 'sidebarCollapse'.tr(),
            iconSize: 18,
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              collapsed
                  ? Icons.keyboard_double_arrow_right
                  : Icons.keyboard_double_arrow_left,
              color: AppColors.textSecondary,
            ),
            onPressed: prefs.toggleSidebar,
          )
        : null;

    final settingsBtn = IconButton(
      tooltip: 'sidebarSettings'.tr(),
      iconSize: 18,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: const Icon(Icons.settings_outlined,
          color: AppColors.textSecondary),
      onPressed: () => showSettingsSheet(context),
    );

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            settingsBtn,
            ?collapseBtn,
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.accentLime,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentLime.withValues(alpha: 0.7),
                  blurRadius: 8,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 800.ms)
              .then()
              .fadeOut(duration: 800.ms),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'sidebarStatus'.tr(namedArgs: {'count': total.toString()}),
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono(
                size: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
          settingsBtn,
          ?collapseBtn,
        ],
      ),
    );
  }
}
