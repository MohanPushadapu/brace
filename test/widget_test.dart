import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brace_yourself/main.dart';

void main() {
  testWidgets('temporary patient bypass opens the app', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Brace Yourself'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Preview patient app'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Temporary bypass for UI preview'), findsOneWidget);

    await tester.tap(find.text('Preview patient app'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Knee brace · Left'), findsOneWidget);

    await tester.tap(find.text('Devices'));
    await tester.pump();

    expect(find.text('Manage your connected rehabilitation gear'), findsOneWidget);

    await tester.tap(find.text('Session'));
    await tester.pump();

    expect(find.text('Live session'), findsOneWidget);
  });

  testWidgets('physician role opens patient statistics', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Physician'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Sign in as physician'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Sign in as physician'), findsOneWidget);

    await tester.tap(find.text('Sign in as physician'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, Dr. Chen'), findsOneWidget);
    expect(find.text('Patient overview'), findsOneWidget);
    expect(find.text('Maya Thompson'), findsOneWidget);
    expect(find.text('Jordan Lee'), findsOneWidget);
  });
}
