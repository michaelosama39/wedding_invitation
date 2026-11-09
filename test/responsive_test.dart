import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wedding_invitation/screens/envelope_screen.dart';
import 'package:wedding_invitation/screens/invitation_page.dart';
import 'package:wedding_invitation/theme.dart';

/// Renders each screen at common device sizes and fails on any overflow.
void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  const sizes = <String, Size>{
    'small phone': Size(320, 568),
    'phone': Size(390, 844),
    'phone landscape': Size(844, 390),
    'tablet': Size(820, 1180),
    'desktop': Size(1440, 900),
  };

  Future<void> pumpAt(WidgetTester tester, Size size, Widget home) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: home));
    await tester.pump(const Duration(seconds: 3));
  }

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('envelope fits on $name', (tester) async {
      await pumpAt(tester, size, EnvelopeScreen(onOpened: () {}));
      expect(tester.takeException(), isNull);
    });

    testWidgets('invitation fits on $name', (tester) async {
      await pumpAt(tester, size, const InvitationPage());
      // Scroll through the whole page so every section lays out.
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 40; i++) {
        await tester.drag(scrollable, Offset(0, -size.height * 0.8));
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
      }
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
