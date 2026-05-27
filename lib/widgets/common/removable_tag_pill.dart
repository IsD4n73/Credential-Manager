import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Tag chip with an X for removal — used in the credential add/edit form.
class RemovableTagPill extends StatelessWidget {
  const RemovableTagPill({
    super.key,
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: AppColors.accentCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: AppTheme.mono(
              size: 12,
              color: AppColors.accentCyan,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 12, color: AppColors.accentCyan),
            ),
          ),
        ],
      ),
    );
  }
}
