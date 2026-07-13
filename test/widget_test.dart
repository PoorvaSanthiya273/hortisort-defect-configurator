import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hortisort_configurator/main.dart';

void main() {
  testWidgets('App smoke test - renders Program Config screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const HortisortApp());
    await tester.pumpAndSettle();

    expect(find.text('Program Configuration'), findsOneWidget);
    expect(find.text('Program Name'), findsOneWidget);
    expect(find.text('Grading Based On'), findsOneWidget);
    expect(find.text('Produce Name'), findsOneWidget);
  });
}
