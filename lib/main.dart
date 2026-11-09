import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'screens/envelope_screen.dart';
import 'screens/invitation_page.dart';
import 'theme.dart';
import 'widgets/language_toggle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WeddingApp());
}

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Changing the locale only swaps Localizations/Directionality, so the
    // envelope, music and scroll position keep their state.
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        AppText.arabic = locale.languageCode == 'ar';
        return MaterialApp(
          onGenerateTitle: S.appTitle.call,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: locale,
          supportedLocales: supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) =>
              Stack(children: [child!, const LanguageToggle()]),
          home: const InvitationRoot(),
        );
      },
    );
  }
}

/// Shows the sealed envelope first, then cross-fades into the invitation.
class InvitationRoot extends StatefulWidget {
  const InvitationRoot({super.key});

  @override
  State<InvitationRoot> createState() => _InvitationRootState();
}

class _InvitationRootState extends State<InvitationRoot> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1200),
      switchInCurve: Curves.easeOut,
      child: _opened
          ? const InvitationPage(key: ValueKey('page'))
          : EnvelopeScreen(
              key: const ValueKey('envelope'),
              onOpened: () => setState(() => _opened = true),
            ),
    );
  }
}
