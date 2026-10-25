import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wedding_invitation/main.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shows sealed envelope first', (tester) async {
    await tester.pumpWidget(const WeddingApp());
    expect(find.text('Tap the seal to open'), findsOneWidget);
  });


  testWidgets('tapping the seal opens the invitation', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const WeddingApp());
    await tester.tap(find.text('G&M').last);
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('TOGETHER WITH THEIR FAMILIES'), findsOneWidget);
  });
}
