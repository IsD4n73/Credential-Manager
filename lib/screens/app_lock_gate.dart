import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../security/biometric.dart';
import '../security/master_password.dart';
import '../state/lock_controller.dart';
import 'lock_screen.dart';

/// Wraps [child] with a lock screen (biometric + master password) when locked.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  bool _initialApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Lock can apply only when there's at least one way to unlock —
  /// biometric or master password.
  bool _canLock(BiometricService bio, MasterPasswordService mp) =>
      bio.lockEnabled && (mp.isSet || bio.supported);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    final bio = context.read<BiometricService>();
    final mp = context.read<MasterPasswordService>();
    if (_canLock(bio, mp)) context.read<LockController>().lock();
  }

  @override
  Widget build(BuildContext context) {
    final bio = context.watch<BiometricService>();
    final mp = context.watch<MasterPasswordService>();
    final lock = context.watch<LockController>();

    // On first build, if the lock can apply, start locked.
    if (!_initialApplied) {
      _initialApplied = true;
      if (_canLock(bio, mp) && !lock.locked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.read<LockController>().lock();
        });
      }
    }

    return Stack(
      children: [
        widget.child,
        if (lock.locked)
          Positioned.fill(
            child: LockScreen(
              onUnlocked: () => context.read<LockController>().unlock(),
            ),
          ),
      ],
    );
  }
}
