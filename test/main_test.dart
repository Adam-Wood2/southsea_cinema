import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/home_view.dart';

const String testPrefDarkMode = "user_dark_mode";

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    rootBundle.clear();
  });

  testWidgets("App displays HomeView as home", (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text("Southsea Cinema & Arts Centre"), findsOneWidget);
  });

  testWidgets("SouthseaCinemaApp defaults to dark mode",
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets("SouthseaCinemaApp loads the saved light mode",
      (WidgetTester tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(<String, Object>{
      testPrefDarkMode: false,
    });

    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets("light and dark themes define readable text colors",
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();
    final MaterialApp darkApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(<String, Object>{
      testPrefDarkMode: false,
    });
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();
    final MaterialApp lightApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );

    expect(darkApp.darkTheme?.colorScheme.brightness, Brightness.dark);
    expect(darkApp.darkTheme?.scaffoldBackgroundColor, cinemaBackground);
    expect(
        darkApp.darkTheme?.appBarTheme.titleTextStyle?.color, cinemaFontWhite);
    expect(lightApp.theme?.colorScheme.brightness, Brightness.light);
    expect(lightApp.theme?.scaffoldBackgroundColor, cinemaLightBackground);
    expect(lightApp.theme?.appBarTheme.titleTextStyle?.color, cinemaFontBlack);
  });

  testWidgets("saving the settings switch updates the root app theme",
      (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip("Open navigation menu"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("My Settings").first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("theme-mode-switch")));
    await tester.tap(find.text("SAVE SETTINGS"));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
