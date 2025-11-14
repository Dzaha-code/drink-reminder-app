import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drink_app/main.dart';

void main() {
  testWidgets('Menambah air +200 ml', (WidgetTester tester) async {
    // Build aplikasi dan trigger frame
    await tester.pumpWidget(const DrinkApp());

    // Verifikasi bahwa nilai awal adalah 0 ml
    expect(find.text('Saat ini: 0 ml'), findsOneWidget);
    expect(find.text('Saat ini: 200 ml'), findsNothing);

    // Tap tombol "+200 ml"
    await tester.tap(find.text('+200 ml'));
    await tester.pump();

    // Verifikasi bahwa nilai sekarang menjadi 200 ml
    expect(find.text('Saat ini: 0 ml'), findsNothing);
    expect(find.text('Saat ini: 200 ml'), findsOneWidget);
  });
}