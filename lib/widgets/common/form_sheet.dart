import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Rounded-top modal bottom sheet for forms.
///
/// Layout:
/// ```
/// ▔▔▔▔▔  drag handle (provided by showModalBottomSheet)
///  Title                                       (×)
/// ─ scrollable body ───────────────────────────────
/// │ ...form fields...                              │
/// │                                                │
/// ─────────────────────────────────────────────────
/// [ Cancel ]                              [ Save ]
/// ```
///
/// Handles safe area + keyboard inset, never exceeds 95% of screen height
/// (configurable via [maxHeightFactor]).
class FormSheet extends StatelessWidget {
  const FormSheet({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.maxHeightFactor = 0.9,
  });

  final Widget title;
  final Widget body;

  /// Each entry is wrapped in [Expanded] inside the bottom action row.
  /// Leave empty to omit the bottom row entirely (the X in the header
  /// is still available to close).
  final List<Widget> actions;
  final double maxHeightFactor;

  /// Convenience launcher: shows [child] inside a properly themed modal
  /// bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: mq.size.height * maxHeightFactor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.titleLarge,
                      child: title,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: body,
              ),
            ),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
