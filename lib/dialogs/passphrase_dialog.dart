import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common/form_sheet.dart';

/// Returns the entered passphrase, or null on cancel.
Future<String?> showPassphraseDialog(
  BuildContext context, {
  required String title,
  required bool confirm,
  required String submitLabel,
}) {
  return FormSheet.show<String>(
    context,
    child: _PassphraseSheet(
      title: title,
      confirm: confirm,
      submitLabel: submitLabel,
    ),
  );
}

class _PassphraseSheet extends StatefulWidget {
  const _PassphraseSheet({
    required this.title,
    required this.confirm,
    required this.submitLabel,
  });
  final String title;
  final bool confirm;
  final String submitLabel;

  @override
  State<_PassphraseSheet> createState() => _PassphraseSheetState();
}

class _PassphraseSheetState extends State<_PassphraseSheet> {
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  bool _reveal = false;

  @override
  void initState() {
    super.initState();
    _p1.addListener(() => setState(() {}));
    _p2.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  bool get _valid {
    if (_p1.text.length < 8) return false;
    if (widget.confirm && _p1.text != _p2.text) return false;
    return true;
  }

  String? get _errorMsg {
    if (_p1.text.isEmpty) return null;
    if (_p1.text.length < 8) return 'passphraseMinLength'.tr();
    if (widget.confirm && _p2.text.isNotEmpty && _p1.text != _p2.text) {
      return 'passphraseMismatch'.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final err = _errorMsg;
    return FormSheet(
      title: Text(widget.title, overflow: TextOverflow.ellipsis),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.confirm
                ? 'passphraseExportBody'.tr()
                : 'passphraseImportBody'.tr(),
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _p1,
            autofocus: true,
            obscureText: !_reveal,
            style: AppTheme.mono(size: 14),
            decoration: InputDecoration(
              labelText: 'passphrasePlaceholder'.tr(),
              suffixIcon: IconButton(
                icon: Icon(
                  _reveal ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _reveal = !_reveal),
              ),
            ),
          ),
          if (widget.confirm) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _p2,
              obscureText: !_reveal,
              style: AppTheme.mono(size: 14),
              decoration:
                  InputDecoration(labelText: 'passphraseConfirm'.tr()),
            ),
          ],
          if (err != null) ...[
            const SizedBox(height: 10),
            Text(err,
                style: const TextStyle(
                    color: AppColors.accentRed, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child:
              Text('commonCancel'.tr(), overflow: TextOverflow.ellipsis),
        ),
        FilledButton(
          onPressed: _valid ? () => Navigator.pop(context, _p1.text) : null,
          child: Text(widget.submitLabel,
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }
}
