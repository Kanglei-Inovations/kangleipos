import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kangleipos/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const PrintonexERP(home: SizedBox.shrink()),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
