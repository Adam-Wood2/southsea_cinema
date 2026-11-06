import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:flutter/material.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/views/settings_view.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  group("App smoke tests", () {
    testWidgets("App displays HomeView as home", (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text("Southsea Cinema & Arts Centre"), findsOneWidget);
    });

    testWidgets("Displays movie cards with name, prices, dates and ratings",
        (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      await tester.pumpAndSettle();

      expect(find.text("Everything Everywhere All At Once"), findsOneWidget);
      expect(find.text("£5.99"), findsOneWidget);
      expect(find.text("(2022) "), findsOneWidget);
      expect(find.text("(PG15) "), findsOneWidget);

      await tester.scrollUntilVisible(find.text("Dracula"), 100);

      expect(find.text("Dracula"), findsOneWidget);
      expect(find.text("£7.99"), findsOneWidget);
      expect(find.text("(1931) "), findsOneWidget);
      expect(find.text("(PG) "), findsOneWidget);

      expect(find.text("Book Now"), findsWidgets);
      expect(find.byType(MovieCard), findsWidgets);

      await tester.scrollUntilVisible(find.text("Bullet Train"), 150);
      expect(find.text("£10.00"), findsOneWidget);
      await tester.scrollUntilVisible(find.text("nonexistant"), 150);
      await tester.pumpAndSettle();
      expect(find.text("£0.00"), findsOneWidget);
      expect(find.text("Image unavailable"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    group("Navigation tests", () {
      setUp(() {
        CartRepository.instance.clear();
      });
      testWidgets(
          "Pressing Book Now navigates to the MovieListing screen with selected movie",
          (WidgetTester tester) async {
        await tester.pumpWidget(const SouthseaCinemaApp());
        await tester.pumpAndSettle();
        //Presses book now on EEAAO movie listing and loads the listing view.
        await tester.tap(find.text("Book Now").first);
        await tester.pumpAndSettle();

        expect(find.byType(MovieListing), findsOneWidget);
        expect(find.text("Book Everything Everywhere All At Once"),
            findsOneWidget);
        expect(find.image(AssetImage("assets/images/EEAAO_poster.jpg")),
            findsOneWidget);
        expect(find.text("Add to order"), findsOneWidget);

        await tester.scrollUntilVisible(find.byType(DropdownMenu<int>), 100,
            scrollable: find.byType(Scrollable).first);

        await tester.tap(find.byType(DropdownMenu<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text("1").last);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add to order"));
        await tester.pumpAndSettle();

        expect(find.text("1 tickets added to basket (£5.99)"), findsOneWidget);
      });

      testWidgets(
          "Navigating to order, booking tickets, return to home screen and book tickets for another movie",
          (WidgetTester tester) async {
        await tester.pumpWidget(const SouthseaCinemaApp());
        await tester.pumpAndSettle();
        //Presses book now on EEAAO movie listing and loads the listing view, selects one ticket and adds to basket
        await tester.tap(find.text("Book Now").first);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(find.byType(DropdownMenu<int>), 100,
            scrollable: find.byType(Scrollable).first);

        await tester.tap(find.byType(DropdownMenu<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text("1").last);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add to order"));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip("Open navigation menu"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Home").first);
        await tester.pumpAndSettle();

        expect(find.byType(HomeView), findsOneWidget);
        expect(CartRepository.instance.getItems().length, 1);

        //Does same as above but for Dracula
        //scrolls down on home view until dracula movie card is found
        await tester.scrollUntilVisible(find.text("Dracula"), 500);

        await tester.tap(find.text("Book Now").last);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(find.byType(DropdownMenu<int>), 100,
            scrollable: find.byType(Scrollable).first);

        expect(find.textContaining("tickets added to basket"), findsNothing);
        await tester.tap(find.byType(DropdownMenu<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text("1").last);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add to order"));
        await tester.pumpAndSettle();

        expect(find.text("1 tickets added to basket (£7.99)"), findsOneWidget);
        expect(CartRepository.instance.getItems().length, 2);
      });

      testWidgets("Booking tickets adds them to the booking screen",
          (WidgetTester tester) async {
        await tester.pumpWidget(const SouthseaCinemaApp());
        await tester.pumpAndSettle();
        //Presses book now on EEAAO movie listing and loads the listing view, selects one ticket and adds to basket
        await tester.tap(find.text("Book Now").first);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(find.byType(DropdownMenu<int>), 100,
            scrollable: find.byType(Scrollable).first);

        await tester.tap(find.byType(DropdownMenu<int>));
        await tester.pumpAndSettle();

        await tester.tap(find.text("1").last);
        await tester.pumpAndSettle();

        await tester.tap(find.text("Add to order"));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip("Open navigation menu"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("My Basket").first);
        await tester.pumpAndSettle();

        expect(find.text("My Order"), findsOneWidget);
        expect(find.text("1 ticket"), findsOneWidget);
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
        final Switch switchWidget = tester.widget<Switch>(find.byType(Switch));
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
        final Switch switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
      });
    });
  });
}
