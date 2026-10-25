import 'package:flutter/material.dart';

import 'screens/envelope_screen.dart';
import 'screens/invitation_page.dart';
import 'theme.dart';

void main() => runApp(const WeddingApp());

class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giulia & Marco — Tuscany Wedding',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const InvitationRoot(),
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
          : EnvelopeScreen(key: const ValueKey('envelope'), onOpened: () => setState(() => _opened = true)),
    );
  }
}
