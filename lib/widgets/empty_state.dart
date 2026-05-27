import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:easy_localization/easy_localization.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../dialogs/credential_dialog.dart';
import '../dialogs/project_dialog.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final noProjects = state.projects.isEmpty;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accentCyan, AppColors.accentMagenta],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentCyan.withValues(alpha: 0.35),
                    blurRadius: 30,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Icon(Icons.vpn_key_outlined,
                  size: 32, color: Color(0xFF001318)),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1, end: 1.08, duration: 1600.ms, curve: Curves.easeInOut),
            const SizedBox(height: 22),
            Text(
              noProjects ? 'emptyNoProjects'.tr() : 'emptyNoCredentials'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              noProjects ? 'emptyNoProjectsBody'.tr() : 'emptyNoCredentialsBody'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {
                if (noProjects) {
                  showProjectDialog(context);
                } else {
                  showCredentialDialog(
                    context,
                    presetProjectId: state.selectedProjectId,
                    presetEnvId: state.selectedEnvId,
                  );
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label:
                  Text(noProjects ? 'emptyBtnCreateProject'.tr() : 'btnNewCredential'.tr()),
            ),
          ],
        ).animate().fadeIn(duration: 360.ms).slideY(
              begin: 0.06,
              end: 0,
              duration: 360.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}
