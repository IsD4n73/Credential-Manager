import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'credential_card.dart';

class CredentialList extends StatelessWidget {
  const CredentialList({
    super.key,
    required this.credentials,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Credential> credentials;
  final String? selectedId;
  final ValueChanged<Credential> onSelect;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return LayoutBuilder(
      builder: (context, c) {
        final crossAxisCount = c.maxWidth >= 1100
            ? 2
            : c.maxWidth >= 720
                ? 2
                : 1;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: AnimationLimiter(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 168,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: credentials.length,
              itemBuilder: (context, index) {
                final cred = credentials[index];
                final project = state.projectById(cred.projectId);
                final env = state.envById(cred.envId);
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: crossAxisCount,
                  duration: const Duration(milliseconds: 360),
                  child: ScaleAnimation(
                    scale: 0.96,
                    child: FadeInAnimation(
                      child: CredentialCard(
                        credential: cred,
                        project: project,
                        env: env,
                        selected: cred.id == selectedId,
                        onTap: () => onSelect(cred),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
