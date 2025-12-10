import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prevoz/app/app.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PrevozApp(),
      ),
    );

    // Verify that the app title is shown
    expect(find.text('Prevoz'), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
  });
}
