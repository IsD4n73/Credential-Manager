import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Read-only "#tag" chip used in cards and detail view.
class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '#$label',
        style: AppTheme.mono(
          size: 10,
          color: AppColors.textSecondary,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Larger pill used in the credential detail view (full tag list).
class TagPillLarge extends StatelessWidget {
  const TagPillLarge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '#$label',
        style: AppTheme.mono(
          size: 11,
          color: AppColors.textPrimary,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}
