import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  group("SettingsView tests", () {
    testWidgets("SettingsView displays form fields and switches",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsView()));

      expect(find.text("Customer Profile"), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text("SAVE SETTINGS"), findsOneWidget);
    });

    testWidgets(
        "Filling in fields and toggling switch, then saving, updates state",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsView()));

      final Finder addressField =
          find.widgetWithText(TextField, "Enter your current home address");
      final Finder emailField =
          find.widgetWithText(TextField, "Enter your email address");
      final Finder patronNumberField =
          find.widgetWithText(TextField, "Enter your patron number");
      final Finder switchFinder = find.byType(Switch);

      await tester.enterText(addressField, "test address");
      await tester.enterText(emailField, "test email");
      await tester.enterText(patronNumberField, "1234");

      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      await tester.tap(switchFinder);
      await tester.pump();
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tester.tap(find.text("SAVE SETTINGS"));
      await tester.pump();

      expect(find.text("Settings saved"), findsOneWidget);
    });
  });
}
