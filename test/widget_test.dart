// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timemanagement/screen/add_screen.dart';

void main() {
  testWidgets('Add Screen test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddScreen()));

    expect(find.byIcon(Icons.calendar_today), findsNothing);
    await tester.tap(find.text('Schedule task'));
    await tester.pump();

    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
  });
}
