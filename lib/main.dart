import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/app_lock_gate.dart';
import 'screens/home_shell.dart';
import 'security/biometric.dart';
import 'security/master_password.dart';
import 'state/app_state.dart';
import 'state/lock_controller.dart';
import 'state/ui_prefs.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // .env is bundled as an asset; missing file is non-fatal for OSS default.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // ignore: empty .env still leaves dotenv.env as an empty map.
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('it')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useFallbackTranslations: true,
      child: const OneCredApp(),
    ),
  );
}

class OneCredApp extends StatelessWidget {
  const OneCredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
        ChangeNotifierProvider(create: (_) => MasterPasswordService()..init()),
        ChangeNotifierProvider(create: (_) => BiometricService()..init()),
        ChangeNotifierProvider(create: (_) => LockController()),
        ChangeNotifierProvider(create: (_) => UiPrefs()..init()),
      ],
      child: MaterialApp(
        onGenerateTitle: (ctx) => 'appTitle'.tr(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        // Localization delegates / supported locales / current locale come
        // from EasyLocalization.
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const AppLockGate(child: HomeShell()),
      ),
    );
  }
}
