import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobplay/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MobPlayApp());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
