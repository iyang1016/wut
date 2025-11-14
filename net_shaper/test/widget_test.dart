import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_shaper/main.dart';

void main() {
  testWidgets('HomePage has a Scan Network button', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Scan Network'), findsOneWidget);
  });
}
