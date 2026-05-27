import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Top bar above the credential list: hamburger (when sidebar isn't pinned),
/// current filter title, search box and "+ new credential" button.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.showMenu,
    required this.onMenu,
    required this.onAdd,
  });

  final bool showMenu;
  final VoidCallback onMenu;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filterParts = <String>[];
    if (state.selectedProjectId != null) {
      final p = state.projectById(state.selectedProjectId!);
      if (p != null) filterParts.add(p.name);
    }
    if (state.selectedEnvId != null) {
      final e = state.envById(state.selectedEnvId!);
      if (e != null) filterParts.add(e.name);
    }
    final filterLabel = filterParts.isEmpty
        ? 'filterAllCredentials'.tr()
        : filterParts.join('  ·  ');

    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 620;
        return Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (showMenu)
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: onMenu,
                ),
              if (!compact) ...[
                Flexible(
                  child: Text(
                    filterLabel,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 18),
              ],
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: TextField(
                    onChanged: state.setSearch,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.textMuted, size: 18),
                      hintText: 'searchPlaceholder'.tr(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (compact)
                FilledButton(
                  onPressed: onAdd,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Icon(Icons.add, size: 18),
                )
              else
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('btnNewCredential'.tr()),
                ),
            ],
          ),
        );
      },
    );
  }
}
