import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/views/settings_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group("SettingsView tests", () {
    testWidgets("SettingsView displays form fields and switches",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsView()));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();
      expect(find.text("Settings saved"), findsOneWidget);

      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      expect(await prefs.getString(prefAddress), "test address");
      expect(await prefs.getString(prefEmail), "test email");
      expect(await prefs.getString(prefPatronNumber), "1234");
      expect(await prefs.getBool(prefNewsletter), isTrue);

      //recreate screen to ensure inputs stay
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MaterialApp(home: SettingsView()));
      await tester.pumpAndSettle();

      expect(find.text("test address"), findsOneWidget);
      expect(find.text("test email"), findsOneWidget);
      expect(find.text("1234"), findsOneWidget);
      final Switch reopenedSwitch = tester.widget<Switch>(find.byType(Switch));
      expect(reopenedSwitch.value, isTrue);
    });

    testWidgets("SettingsView pre-fills saved settings on opening",
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(<String, Object>{
        prefAddress: "test address",
        prefEmail: "test@email.com",
        prefPatronNumber: "1234",
        prefNewsletter: true
      });

      await tester.pumpWidget(const MaterialApp(home: SettingsView()));
      await tester.pumpAndSettle();

      expect(find.text("test address"), findsOneWidget);
      expect(find.text("test@email.com"), findsOneWidget);
      expect(find.text("1234"), findsOneWidget);
      final Switch switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });
  });
}
