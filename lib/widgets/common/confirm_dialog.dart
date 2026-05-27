import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'form_sheet.dart';

/// Shared "are you sure?" confirmation as a bottom sheet with rounded top
/// (same visual language as the form sheets). Returns true if confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final r = await FormSheet.show<bool>(
    context,
    child: _ConfirmSheet(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
  return r ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.body,
    this.confirmLabel,
    this.cancelLabel,
  });

  final String title;
  final String body;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: Text(title, overflow: TextOverflow.ellipsis),
      body: Text(
        body,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? 'commonCancel'.tr(),
              overflow: TextOverflow.ellipsis),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? 'commonDelete'.tr(),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
