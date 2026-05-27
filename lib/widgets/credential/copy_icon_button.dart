import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Tiny icon-only button that copies [value] to the clipboard and shows a
/// "copied" snackbar.
class CopyIconButton extends StatelessWidget {
  const CopyIconButton({super.key, required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'detailCopy'.tr(),
      splashRadius: 18,
      icon: const Icon(Icons.copy_outlined,
          size: 16, color: AppColors.accentCyan),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('detailCopied'.tr()),
            duration: const Duration(milliseconds: 1200),
          ),
        );
      },
    );
  }
}
