import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../security/biometric.dart';
import '../security/master_password.dart';
import '../theme/app_theme.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});
  final VoidCallback onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _password = TextEditingController();
  bool _bioRunning = false;
  bool _bioTriedThisMount = false;
  String? _error;
  bool _reveal = false;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bio = context.read<BiometricService>();
      if (bio.supported && !_bioTriedThisMount) {
        _tryBiometric();
      }
    });
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    if (_bioRunning) return;
    setState(() {
      _bioRunning = true;
      _bioTriedThisMount = true;
      _error = null;
    });
    final bio = context.read<BiometricService>();
    final ok = await bio.authenticate(reason: 'lockReason'.tr());
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _bioRunning = false;
      });
    }
  }

  Future<void> _tryPassword() async {
    if (_verifying || _password.text.isEmpty) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    final mp = context.read<MasterPasswordService>();
    final ok = await mp.verify(_password.text);
    if (!mounted) return;
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() {
        _verifying = false;
        _error = 'lockPasswordError'.tr();
        _password.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bio = context.watch<BiometricService>();
    final icon = bio.availableTypes.contains(BiometricType.face)
        ? Icons.face_outlined
        : bio.availableTypes.contains(BiometricType.fingerprint)
            ? Icons.fingerprint
            : Icons.lock_outline;
    final bioMethod = switch (bio.friendlyTypeKey) {
      'face' => 'bioFaceId'.tr(),
      'fingerprint' => 'bioFingerprint'.tr(),
      'iris' => 'bioIris'.tr(),
      'biometrics' => 'bioBiometrics'.tr(),
      _ => 'bioDevicePin'.tr(),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentCyan,
                          AppColors.accentMagenta
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Icon(icon,
                        size: 40, color: const Color(0xFF001318)),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                          begin: 1,
                          end: 1.05,
                          duration: 1400.ms,
                          curve: Curves.easeInOut),
                  const SizedBox(height: 22),
                  Text(
                    'sidebarBrand'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 26,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'lockSubtitle'.tr(),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 26),
                  if (bio.supported) ...[
                    OutlinedButton.icon(
                      onPressed: _bioRunning ? null : _tryBiometric,
                      icon: const Icon(Icons.fingerprint, size: 18),
                      label: Text(
                        _bioRunning
                            ? 'lockRunning'.tr()
                            : 'lockUseBiometric'
                                .tr(namedArgs: {'method': bioMethod}),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  TextField(
                    controller: _password,
                    autofocus: !bio.supported,
                    obscureText: !_reveal,
                    style: AppTheme.mono(size: 14),
                    onSubmitted: (_) => _tryPassword(),
                    decoration: InputDecoration(
                      labelText: 'lockPasswordPlaceholder'.tr(),
                      prefixIcon: const Icon(Icons.key_outlined,
                          color: AppColors.textMuted, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _reveal ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _reveal = !_reveal),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style:
                            const TextStyle(color: AppColors.accentRed)),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (_verifying || _password.text.isEmpty)
                          ? null
                          : _tryPassword,
                      icon: const Icon(Icons.lock_open_outlined, size: 18),
                      label: Text(_verifying
                          ? 'lockRunning'.tr()
                          : 'lockUnlock'.tr()),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.04, end: 0, duration: 320.ms),
            ),
          ),
        ),
      ),
    );
  }
}
