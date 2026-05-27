import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'copy_icon_button.dart';

/// Secret field with reveal/hide toggle, copy button and a magenta glow
/// when revealed.
class SecretField extends StatelessWidget {
  const SecretField({
    super.key,
    required this.value,
    required this.revealed,
    required this.onToggle,
  });

  final String value;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final display = revealed ? value : '•' * (value.length.clamp(8, 24));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'detailSecretLabel'.tr(),
          style: AppTheme.mono(
                  size: 10,
                  color: AppColors.textMuted,
                  weight: FontWeight.w700)
              .copyWith(letterSpacing: 1.4),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: revealed
                  ? AppColors.accentMagenta.withValues(alpha: 0.6)
                  : AppColors.border,
            ),
            boxShadow: revealed
                ? [
                    BoxShadow(
                      color: AppColors.accentMagenta.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  display,
                  style: AppTheme.mono(
                      size: 13,
                      color: revealed
                          ? AppColors.accentLime
                          : AppColors.textSecondary),
                ),
              ),
              IconButton(
                tooltip: revealed ? 'detailHide'.tr() : 'detailReveal'.tr(),
                splashRadius: 18,
                icon: Icon(
                  revealed ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: onToggle,
              ),
              CopyIconButton(value: value),
            ],
          ),
        ),
      ],
    );
  }
}
