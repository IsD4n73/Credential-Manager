import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../dialogs/credential_dialog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../state/ui_prefs.dart';
import '../theme/app_theme.dart';
import '../widgets/credential_detail.dart';
import '../widgets/credential_list.dart';
import '../widgets/empty_state.dart';
import '../widgets/mobile_detail_sheet.dart';
import '../widgets/sidebar/sidebar.dart';
import '../widgets/top_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  Credential? _selected;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
      );
    }

    if (_selected != null &&
        !state.credentials.any((c) => c.id == _selected!.id)) {
      _selected = null;
    }

    final prefs = context.watch<UiPrefs>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;
        final isMedium = constraints.maxWidth >= 720;

        final collapsed = prefs.sidebarCollapsed && isMedium;
        final expandedWidth = isWide ? 280.0 : 240.0;
        final sidebarWidth = collapsed ? 68.0 : expandedWidth;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isMedium
              ? null
              : Drawer(
                  backgroundColor: AppColors.surface,
                  width: 280,
                  child: SafeArea(
                    child: Sidebar(
                      canCollapse: false,
                      onProjectTap: (_) => Navigator.of(context).maybePop(),
                      onEnvTap: (_) => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isMedium)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    width: sidebarWidth,
                    child: Sidebar(collapsed: collapsed),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        showMenu: !isMedium,
                        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                        onAdd: () => _addCredential(context),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: state.credentials.isEmpty
                                  ? const EmptyState()
                                  : CredentialList(
                                      credentials: state.credentials,
                                      selectedId: _selected?.id,
                                      onSelect: (c) =>
                                          setState(() => _selected = c),
                                    ),
                            ),
                            if (isWide && _selected != null)
                              SizedBox(
                                width: 420,
                                child: CredentialDetail(
                                  credential: _selected!,
                                  onClose: () =>
                                      setState(() => _selected = null),
                                ).animate().fadeIn(duration: 200.ms).slideX(
                                      begin: 0.1,
                                      end: 0,
                                      duration: 240.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: !isWide && _selected != null
              ? MobileDetailSheet(
                  credential: _selected!,
                  onClose: () => setState(() => _selected = null),
                )
              : null,
        );
      },
    );
  }

  Future<void> _addCredential(BuildContext context) async {
    final state = context.read<AppState>();
    if (state.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('msgCreateProjectFirst'.tr())),
      );
      return;
    }
    await showCredentialDialog(
      context,
      presetProjectId: state.selectedProjectId,
      presetEnvId: state.selectedEnvId,
    );
  }
}
