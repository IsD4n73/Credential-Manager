import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Uppercase mono label used as the heading of a section in dialogs/sheets.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.mono(
              size: 10, color: AppColors.textMuted, weight: FontWeight.w700)
          .copyWith(letterSpacing: 1.5),
    );
  }
}
