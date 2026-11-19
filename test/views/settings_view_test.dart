import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/settings_view.dart';

const String testPrefDarkMode = "user_dark_mode";

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    rootBundle.clear();
  });

  group("SettingsView tests", () {
    testWidgets("SettingsView displays form fields and switches",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsView()));
      await tester.pumpAndSettle();

      expect(find.text("Customer Profile"), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.byKey(const Key("theme-mode-switch")), findsOneWidget);
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
      final Finder switchFinder = find.byKey(const Key("newsletter-switch"));

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
      final Switch reopenedSwitch =
          tester.widget<Switch>(find.byKey(const Key("newsletter-switch")));
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
      final Switch switchWidget =
          tester.widget<Switch>(find.byKey(const Key("newsletter-switch")));
      expect(switchWidget.value, isTrue);
    });

    testWidgets("theme switch defaults to dark mode",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsView()));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Switch>(find.byKey(const Key("theme-mode-switch"))).value,
        isTrue,
      );
    });

    testWidgets("theme switch loads the saved light mode",
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(<String, Object>{
        testPrefDarkMode: false,
      });

      await tester.pumpWidget(const MaterialApp(home: SettingsView()));
      await tester.pumpAndSettle();

      expect(
        tester.widget<Switch>(find.byKey(const Key("theme-mode-switch"))).value,
        isFalse,
      );
    });

    testWidgets("saving the theme switch persists and reports the selected mode",
        (WidgetTester tester) async {
      ThemeMode? savedThemeMode;
      await tester.pumpWidget(MaterialApp(
        home: SettingsView(
          onThemeModeSaved: (ThemeMode themeMode) {
            savedThemeMode = themeMode;
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("theme-mode-switch")));
      await tester.tap(find.text("SAVE SETTINGS"));
      await tester.pumpAndSettle();

      expect(savedThemeMode, ThemeMode.light);
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      expect(await prefs.getBool(testPrefDarkMode), isFalse);
    });
  });

  group("Settings persistance tests", () {
    testWidgets("SettingsView text fields are blank by default",
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip("Open navigation menu"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("My Settings").first);
      await tester.pumpAndSettle();

      expect(find.text("Enter your current home address"), findsOneWidget);
      expect(find.text("Enter your email address"), findsOneWidget);
      expect(find.text("Enter your patron number"), findsOneWidget);
      final Switch switchWidget =
          tester.widget<Switch>(find.byKey(const Key("newsletter-switch")));
      expect(switchWidget.value, isFalse);
    });

    testWidgets(
        "SettingsView loads pre-filled values when navigated to from HomeView",
        (WidgetTester tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(<String, Object>{
        prefAddress: "test address",
        prefEmail: "test@email.com",
        prefPatronNumber: "1234",
        prefNewsletter: true
      });

      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip("Open navigation menu"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("My Settings").first);
      await tester.pumpAndSettle();
      expect(find.text("test address"), findsOneWidget);
      expect(find.text("test@email.com"), findsOneWidget);
      expect(find.text("1234"), findsOneWidget);
      final Switch switchWidget =
          tester.widget<Switch>(find.byKey(const Key("newsletter-switch")));
      expect(switchWidget.value, isTrue);
    });
  });

}
