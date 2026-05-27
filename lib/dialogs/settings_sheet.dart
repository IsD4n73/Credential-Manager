import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../security/biometric.dart';
import '../security/master_password.dart';
import '../security/vault_crypto.dart';
import '../security/vault_io.dart';
import '../state/app_state.dart';
import '../state/lock_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common/form_sheet.dart';
import '../widgets/common/section_label.dart';
import '../widgets/common/settings_row.dart';
import 'passphrase_dialog.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return FormSheet.show<void>(context, child: const _SettingsSheet());
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final bio = context.watch<BiometricService>();
    final mp = context.watch<MasterPasswordService>();
    return FormSheet(
      title: Text('settingsTitle'.tr(), overflow: TextOverflow.ellipsis),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('settingsSecurity'.tr()),
          const SizedBox(height: 8),
          SettingsRow(
            icon: Icons.fingerprint,
            iconColor: AppColors.accentLime,
            title: 'settingsBiometric'.tr(),
            subtitle: bio.supported
                ? 'settingsBiometricSubtitle'.tr(
                    namedArgs: {'method': _localizedBio(bio.friendlyTypeKey)})
                : 'settingsBiometricUnavailable'.tr(),
            trailing: Switch(
              value: bio.lockEnabled,
              activeThumbColor: AppColors.accentCyan,
              onChanged: (v) async {
                if (v) {
                  await _enableLock(context, bio, mp);
                } else {
                  await bio.setLockEnabled(false);
                }
              },
            ),
          ),
          const SizedBox(height: 6),
          SettingsRow(
            icon: Icons.password_outlined,
            iconColor: AppColors.accentCyan,
            title: 'settingsChangePassword'.tr(),
            subtitle: 'settingsChangePasswordSubtitle'.tr(),
            enabled: mp.isSet,
            onTap: () async {
              final ctx = context;
              Navigator.pop(ctx);
              final pwd = await showPassphraseDialog(
                ctx,
                title: 'masterTitleChange'.tr(),
                confirm: true,
                submitLabel: 'masterSubmitChange'.tr(),
              );
              if (pwd != null) await mp.set(pwd);
            },
          ),
          const SizedBox(height: 6),
          SettingsRow(
            icon: Icons.lock_outline,
            iconColor: AppColors.accentMagenta,
            title: 'settingsLockNow'.tr(),
            subtitle: 'settingsLockNowSubtitle'.tr(),
            enabled: bio.lockEnabled,
            onTap: () {
              Navigator.pop(context);
              context.read<LockController>().lock();
            },
          ),
          const SizedBox(height: 24),
          SectionLabel('settingsAppearance'.tr()),
          const SizedBox(height: 8),
          const _LanguageRow(),
          const SizedBox(height: 24),
          SectionLabel('settingsData'.tr()),
          const SizedBox(height: 8),
          SettingsRow(
            icon: Icons.upload_outlined,
            iconColor: AppColors.accentCyan,
            title: 'settingsExport'.tr(),
            subtitle: 'settingsExportSubtitle'.tr(),
            onTap: () async {
              final ctx = context;
              Navigator.pop(ctx);
              await _runExport(ctx);
            },
          ),
          const SizedBox(height: 6),
          SettingsRow(
            icon: Icons.download_outlined,
            iconColor: AppColors.accentViolet,
            title: 'settingsImport'.tr(),
            subtitle: 'settingsImportSubtitle'.tr(),
            onTap: () async {
              final ctx = context;
              Navigator.pop(ctx);
              await _runImport(ctx);
            },
          ),
          const SizedBox(height: 22),
          _InfoCard(),
        ],
      ),
    );
  }

  Future<void> _enableLock(
    BuildContext context,
    BiometricService bio,
    MasterPasswordService mp,
  ) async {
    if (!mp.isSet) {
      final pwd = await showPassphraseDialog(
        context,
        title: 'masterTitleSetup'.tr(),
        confirm: true,
        submitLabel: 'masterSubmitSetup'.tr(),
      );
      if (pwd == null) return;
      await mp.set(pwd);
    }
    if (bio.supported) {
      final ok = await bio.authenticate(reason: 'settingsConfirmEnable'.tr());
      if (!ok) return;
    }
    await bio.setLockEnabled(true);
  }

  String _localizedBio(String key) {
    switch (key) {
      case 'face':
        return 'bioFaceId'.tr();
      case 'fingerprint':
        return 'bioFingerprint'.tr();
      case 'iris':
        return 'bioIris'.tr();
      case 'biometrics':
        return 'bioBiometrics'.tr();
      default:
        return 'bioDevicePin'.tr();
    }
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'settingsInfo'.tr(),
                  style: AppTheme.mono(
                      size: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: VaultCrypto.hasPepper
                    ? AppColors.accentLime
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Text(
                VaultCrypto.hasPepper
                    ? 'settingsPepperOn'.tr()
                    : 'settingsPepperOff'.tr(),
                style: AppTheme.mono(
                    size: 10,
                    color: VaultCrypto.hasPepper
                        ? AppColors.accentLime
                        : AppColors.textMuted,
                    weight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _runExport(BuildContext context) async {
  final pass = await showPassphraseDialog(
    context,
    title: 'passphraseExportTitle'.tr(),
    confirm: true,
    submitLabel: 'passphraseExportSubmit'.tr(),
  );
  if (pass == null) return;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final path = await VaultIO.exportEncrypted(pass);
    if (path != null) {
      messenger.showSnackBar(SnackBar(
          content: Text('exportSaved'.tr(namedArgs: {'path': path}))));
    }
  } catch (e) {
    messenger.showSnackBar(SnackBar(
        content: Text('exportError'.tr(namedArgs: {'error': e.toString()}))));
  }
}

Future<void> _runImport(BuildContext context) async {
  final pass = await showPassphraseDialog(
    context,
    title: 'passphraseImportTitle'.tr(),
    confirm: false,
    submitLabel: 'passphraseImportSubmit'.tr(),
  );
  if (pass == null) return;
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final state = context.read<AppState>();
  try {
    final res = await VaultIO.importEncrypted(pass);
    if (res != null) {
      await state.reloadAll();
      messenger.showSnackBar(SnackBar(
        content: Text('importDone'.tr(namedArgs: {
          'creds': res.credentials.toString(),
          'projects': res.projects.toString(),
          'envs': res.envs.toString(),
        })),
      ));
    }
  } on VaultIOError {
    messenger
        .showSnackBar(SnackBar(content: Text('importWrongPassphrase'.tr())));
  } catch (e) {
    messenger.showSnackBar(SnackBar(
        content: Text('importError'.tr(namedArgs: {'error': e.toString()}))));
  }
}

/// Settings row that opens a sheet with the three language options.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  String _currentLabel(BuildContext context) {
    final code = context.locale.languageCode;
    if (code == 'it') return 'langItalian'.tr();
    return 'langEnglish'.tr();
  }

  Future<void> _open(BuildContext context) async {
    final chosen = await FormSheet.show<String>(
      context,
      child: _LanguageSheet(activeCode: context.locale.languageCode),
    );
    if (chosen == null || !context.mounted) return;
    final el = EasyLocalization.of(context)!;
    if (chosen == '__system__') {
      await el.deleteSaveLocale();
      await el.resetLocale();
    } else {
      await el.setLocale(Locale(chosen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.translate,
      iconColor: AppColors.accentOrange,
      title: 'settingsLanguage'.tr(),
      subtitle: 'settingsLanguageSubtitle'
          .tr(namedArgs: {'current': _currentLabel(context)}),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textMuted, size: 18),
      onTap: () => _open(context),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.activeCode});
  final String activeCode;

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, String value) {
      final selected =
          value == activeCode || (value == '__system__' && false);
      return InkWell(
        onTap: () => Navigator.pop(context, value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check, color: AppColors.accentCyan, size: 20),
            ],
          ),
        ),
      );
    }

    return FormSheet(
      title: Text('settingsLanguage'.tr(), overflow: TextOverflow.ellipsis),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile('langSystem'.tr(), '__system__'),
          tile('langEnglish'.tr(), 'en'),
          tile('langItalian'.tr(), 'it'),
        ],
      ),
    );
  }
}
