import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/square_button.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets("SquareButton renders a text lebel", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SquareButton(label: "Order", onPressed: () {})),
    ));

    expect(find.text("Order"), findsOneWidget);
  });

  testWidgets("SquareButton renders a icon", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SquareButton(
                label: "Order",
                icon: Icon(Icons.shopping_cart),
                onPressed: () {}))));
  });

  testWidgets("SquareButton invokes onPressed when tapped",
      (WidgetTester tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SquareButton(
                label: "Order",
                onPressed: () {
                  wasPressed = true;
                }))));

    await tester.tap(find.text("Order"));
    await tester.pump();

    expect(wasPressed, isTrue);
  });
}
