import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/credential_dialog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'common/confirm_dialog.dart';
import 'common/env_badge.dart';
import 'common/glow_dot.dart';
import 'common/tag_pill.dart';
import 'credential/readable_field.dart';
import 'credential/secret_field.dart';

class CredentialDetail extends StatefulWidget {
  const CredentialDetail({
    super.key,
    required this.credential,
    required this.onClose,
    this.scrollController,
  });

  final Credential credential;
  final VoidCallback onClose;
  final ScrollController? scrollController;

  @override
  State<CredentialDetail> createState() => _CredentialDetailState();
}

class _CredentialDetailState extends State<CredentialDetail> {
  bool _revealed = false;

  @override
  void didUpdateWidget(covariant CredentialDetail old) {
    super.didUpdateWidget(old);
    if (old.credential.id != widget.credential.id) _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cred = widget.credential;
    final project = state.projectById(cred.projectId);
    final env = state.envById(cred.envId);
    final pColor = project?.color ?? AppColors.accentCyan;
    final eColor = env?.color ?? AppColors.textMuted;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              projectName: project?.name ?? '—',
              projectColor: pColor,
              envName: env?.name ?? '—',
              envColor: eColor,
              onClose: widget.onClose,
            ),
            const SizedBox(height: 18),
            Text(
              cred.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 28),
            if ((cred.username ?? '').isNotEmpty)
              ReadableField(
                  label: 'USERNAME', value: cred.username!, copyable: true),
            const SizedBox(height: 14),
            SecretField(
              value: cred.secret,
              revealed: _revealed,
              onToggle: () => setState(() => _revealed = !_revealed),
            ),
            if ((cred.url ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              ReadableField(label: 'URL', value: cred.url!, copyable: true),
            ],
            if (cred.tags.isNotEmpty) _TagSection(tags: cred.tags),
            if ((cred.notes ?? '').isNotEmpty) _NotesSection(notes: cred.notes!),
            const SizedBox(height: 28),
            _ActionRow(
              credential: cred,
              onClose: widget.onClose,
            ),
            const SizedBox(height: 14),
            Text(
              'detailUpdated'.tr(
                  namedArgs: {'time': _relativeTime(cred.updatedAt)}),
              style: AppTheme.mono(size: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'timeNow'.tr();
    if (diff.inMinutes < 60) {
      return 'timeMinutes'.tr(namedArgs: {'n': diff.inMinutes.toString()});
    }
    if (diff.inHours < 24) {
      return 'timeHours'.tr(namedArgs: {'n': diff.inHours.toString()});
    }
    if (diff.inDays < 30) {
      return 'timeDays'.tr(namedArgs: {'n': diff.inDays.toString()});
    }
    return '${t.day}/${t.month}/${t.year}';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.projectName,
    required this.projectColor,
    required this.envName,
    required this.envColor,
    required this.onClose,
  });

  final String projectName;
  final Color projectColor;
  final String envName;
  final Color envColor;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Project chip — flexible so a long project name truncates instead
        // of overflowing the header on narrow screens (mobile bottom sheet).
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: projectColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: projectColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlowDot(color: projectColor, size: 7),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    projectName,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: AppTheme.mono(
                        size: 11,
                        color: AppColors.textPrimary,
                        weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        EnvBadge(label: envName, color: envColor),
        const Spacer(),
        IconButton(
          tooltip: 'commonClose'.tr(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'detailTags'.tr(),
            style: AppTheme.mono(
                    size: 10,
                    color: AppColors.textMuted,
                    weight: FontWeight.w700)
                .copyWith(letterSpacing: 1.3),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) => TagPillLarge(label: t)).toList(),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'detailNotes'.tr(),
            style: AppTheme.mono(
                    size: 10,
                    color: AppColors.textMuted,
                    weight: FontWeight.w700)
                .copyWith(letterSpacing: 1.3),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              notes,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.credential, required this.onClose});
  final Credential credential;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                showCredentialDialog(context, existing: credential),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text('commonEdit'.tr()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: BorderSide(
                  color: AppColors.accentRed.withValues(alpha: 0.5)),
            ),
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'confirmDeleteCredentialTitle'.tr(),
                body: 'confirmDeleteBody'.tr(),
              );
              if (ok && context.mounted) {
                await context.read<AppState>().deleteCredential(credential.id);
                onClose();
              }
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('commonDelete'.tr()),
          ),
        ),
      ],
    );
  }
}
