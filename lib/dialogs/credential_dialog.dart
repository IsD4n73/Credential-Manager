import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common/env_color_bar.dart';
import '../widgets/common/form_sheet.dart';
import '../widgets/common/glow_dot.dart';
import '../widgets/common/labeled_dropdown.dart';
import '../widgets/common/removable_tag_pill.dart';
import 'env_dialog.dart';
import 'project_dialog.dart';

Future<void> showCredentialDialog(
  BuildContext context, {
  Credential? existing,
  String? presetProjectId,
  String? presetEnvId,
}) {
  return FormSheet.show<void>(
    context,
    child: _CredentialSheet(
      existing: existing,
      presetProjectId: presetProjectId,
      presetEnvId: presetEnvId,
    ),
  );
}

class _CredentialSheet extends StatefulWidget {
  const _CredentialSheet({
    this.existing,
    this.presetProjectId,
    this.presetEnvId,
  });
  final Credential? existing;
  final String? presetProjectId;
  final String? presetEnvId;

  @override
  State<_CredentialSheet> createState() => _CredentialSheetState();
}

class _CredentialSheetState extends State<_CredentialSheet> {
  late TextEditingController _name;
  late TextEditingController _username;
  late TextEditingController _secret;
  late TextEditingController _url;
  late TextEditingController _notes;
  late TextEditingController _tagInput;
  late List<String> _tags;
  String? _projectId;
  String? _envId;
  bool _showSecret = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _username = TextEditingController(text: e?.username ?? '');
    _secret = TextEditingController(text: e?.secret ?? '');
    _url = TextEditingController(text: e?.url ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _tagInput = TextEditingController();
    _tags = List.of(e?.tags ?? const []);
    _projectId = e?.projectId ?? widget.presetProjectId;
    _envId = e?.envId ?? widget.presetEnvId;
    _name.addListener(() => setState(() {}));
    _secret.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _secret.dispose();
    _url.dispose();
    _notes.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final t = raw.trim().replaceAll(RegExp(r'\s+'), '-').toLowerCase();
    if (t.isEmpty || _tags.contains(t)) {
      _tagInput.clear();
      return;
    }
    setState(() {
      _tags.add(t);
      _tagInput.clear();
    });
  }

  bool get _isValid =>
      _name.text.trim().isNotEmpty &&
      _secret.text.isNotEmpty &&
      _projectId != null &&
      _envId != null;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    _projectId ??= state.projects.isNotEmpty ? state.projects.first.id : null;
    _envId ??= state.envs.isNotEmpty ? state.envs.first.id : null;
    final isEdit = widget.existing != null;

    return FormSheet(
      title: Text(
        isEdit
            ? 'dialogCredentialEditTitle'.tr()
            : 'dialogCredentialNewTitle'.tr(),
        overflow: TextOverflow.ellipsis,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project + Env: side-by-side on wide sheets, stacked on narrow ones.
          LayoutBuilder(
            builder: (context, c) {
              final stack = c.maxWidth < 380;
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _projectDropdown(state),
                    const SizedBox(height: 12),
                    _envDropdown(state),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _projectDropdown(state)),
                  const SizedBox(width: 12),
                  Expanded(child: _envDropdown(state)),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            autofocus: !isEdit,
            decoration: InputDecoration(
              labelText: 'fieldName'.tr(),
              hintText: 'dialogCredentialNameHint'.tr(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _username,
            decoration: InputDecoration(labelText: 'fieldUsername'.tr()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secret,
            obscureText: !_showSecret,
            style: AppTheme.mono(size: 13),
            decoration: InputDecoration(
              labelText: 'fieldSecret'.tr(),
              hintText: 'fieldSecretHint'.tr(),
              suffixIcon: IconButton(
                icon: Icon(
                  _showSecret ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _showSecret = !_showSecret),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            decoration: InputDecoration(labelText: 'fieldUrl'.tr()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagInput,
            onSubmitted: _addTag,
            decoration: InputDecoration(
              labelText: 'fieldTagsLabel'.tr(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add,
                    size: 18, color: AppColors.accentCyan),
                onPressed: () => _addTag(_tagInput.text),
              ),
            ),
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags
                  .map((t) => RemovableTagPill(
                        label: t,
                        onRemove: () => setState(() => _tags.remove(t)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'fieldNotes'.tr()),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('commonCancel'.tr(), overflow: TextOverflow.ellipsis),
        ),
        FilledButton(
          onPressed: _isValid ? _save : null,
          child: Text(
            isEdit ? 'commonSave'.tr() : 'btnCreateCredential'.tr(),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _projectDropdown(AppState state) {
    return LabeledDropdown<String>(
      label: 'fieldProject'.tr(),
      value: _projectId,
      items: [
        for (final p in state.projects)
          DropdownMenuItem(
            value: p.id,
            child: Row(
              children: [
                GlowDot(color: p.color, glow: false),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
      onChanged: (v) => setState(() => _projectId = v),
      trailing: IconButton(
        tooltip: 'sidebarNewProject'.tr(),
        icon: const Icon(Icons.add, size: 16, color: AppColors.accentCyan),
        onPressed: () => showProjectDialog(context),
      ),
    );
  }

  Widget _envDropdown(AppState state) {
    return LabeledDropdown<String>(
      label: 'fieldEnvironment'.tr(),
      value: _envId,
      items: [
        for (final e in state.envs)
          DropdownMenuItem(
            value: e.id,
            child: Row(
              children: [
                EnvColorBar(color: e.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono(
                      size: 13,
                      color: AppColors.textPrimary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: (v) => setState(() => _envId = v),
      trailing: IconButton(
        tooltip: 'sidebarNewEnvironment'.tr(),
        icon: const Icon(Icons.add, size: 16, color: AppColors.accentCyan),
        onPressed: () => showEnvDialog(context),
      ),
    );
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    if (widget.existing != null) {
      await state.updateCredential(widget.existing!.copyWith(
        projectId: _projectId!,
        envId: _envId!,
        name: _name.text.trim(),
        username: _username.text.trim().isEmpty ? null : _username.text.trim(),
        secret: _secret.text,
        url: _url.text.trim().isEmpty ? null : _url.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        tags: _tags,
      ));
    } else {
      await state.createCredential(
        projectId: _projectId!,
        envId: _envId!,
        name: _name.text.trim(),
        username: _username.text.trim().isEmpty ? null : _username.text.trim(),
        secret: _secret.text,
        url: _url.text.trim().isEmpty ? null : _url.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        tags: _tags,
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
