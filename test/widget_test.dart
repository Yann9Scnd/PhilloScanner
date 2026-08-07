import 'package:flutter_test/flutter_test.dart';
import 'package:chiliguard/main.dart';

void main() {
  testWidgets('Phylloscanner app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PhylloscannerApp());
    expect(find.text('Phylloscanner'), findsWidgets);
  });
}
