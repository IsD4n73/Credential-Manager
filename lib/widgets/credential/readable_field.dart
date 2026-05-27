import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'copy_icon_button.dart';

/// Read-only "field" box used in the credential detail screen. Renders a
/// small label on top and the value inside a rounded container with an
/// optional copy-to-clipboard button.
class ReadableField extends StatelessWidget {
  const ReadableField({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.mono(
                  size: 10,
                  color: AppColors.textMuted,
                  weight: FontWeight.w700)
              .copyWith(letterSpacing: 1.4),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: AppTheme.mono(size: 13, color: AppColors.textPrimary),
                ),
              ),
              if (copyable) CopyIconButton(value: value),
            ],
          ),
        ),
      ],
    );
  }
}
