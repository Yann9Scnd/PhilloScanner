import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phylloscanner/screens/dashboard_screen.dart';

void main() {
  const sizes = <Size>[Size(390, 844), Size(320, 568), Size(412, 915), Size(800, 600)];

  for (final size in sizes) {
    testWidgets('Dashboard renders on ${size.width.toInt()}x${size.height.toInt()}',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull,
          reason: 'Dashboard harus render tanpa overflow/error di $size');
    });
  }
}
