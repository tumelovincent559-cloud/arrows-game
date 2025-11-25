import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arrows_puzzle/main.dart'; // correct package name

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // MyApp is const, so load using const
    await tester.pumpWidget(const MyApp());

    // The app should build a MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
