import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

const String themePreferenceKey = "user_dark_mode";

const Movie themeTestMovie = Movie(
  id: "theme-test",
  name: "Theme Test Movie",
  releaseYear: 2026,
  ageRating: "PG",
  description: "A movie used for theme tests.",
  price: 5.99,
  date: "01/01/2026",
  time: "19:00",
  imagePath: "missing-image.png",
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    rootBundle.clear();
    CartRepository.instance.clear();
  });

  Future<ThemeData> loadTheme(WidgetTester tester, ThemeMode mode) async {
    if (mode == ThemeMode.light) {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(<String, Object>{
        themePreferenceKey: false,
      });
    }

    await tester.pumpWidget(const SouthseaCinemaApp());
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    return mode == ThemeMode.light ? app.theme! : app.darkTheme!;
  }

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
    expect(find.text("Book Everything Everywhere All At Once"), findsOneWidget);
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

  testWidgets("movie card uses light text in dark mode",
      (WidgetTester tester) async {
    final ThemeData darkTheme = await loadTheme(tester, ThemeMode.dark);

    await tester.pumpWidget(MaterialApp(
      theme: darkTheme,
      home: const Scaffold(body: MovieCard(movie: themeTestMovie)),
    ));

    final Text title = tester.widget<Text>(find.text(themeTestMovie.name));
    final Card card = tester.widget<Card>(find.byType(Card));
    expect(title.style?.color, darkTheme.colorScheme.onSurface);
    expect(card.color, darkTheme.colorScheme.surface);
  });

  testWidgets("movie card uses dark text in light mode",
      (WidgetTester tester) async {
    final ThemeData lightTheme = await loadTheme(tester, ThemeMode.light);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      home: const Scaffold(body: MovieCard(movie: themeTestMovie)),
    ));

    final Text title = tester.widget<Text>(find.text(themeTestMovie.name));
    expect(title.style?.color, lightTheme.colorScheme.onSurface);
  });

  testWidgets("drawer uses the active surface and text colors",
      (WidgetTester tester) async {
    final ThemeData lightTheme = await loadTheme(tester, ThemeMode.light);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      home: Scaffold(appBar: AppBar(), drawer: const NavDrawer()),
    ));
    await tester.tap(find.byTooltip("Open navigation menu"));
    await tester.pumpAndSettle();

    final Drawer drawer = tester.widget<Drawer>(find.byType(Drawer));
    final Text tileText = tester.widget<Text>(find.text("My Settings"));
    expect(drawer.backgroundColor, lightTheme.colorScheme.surface);
    expect(tileText.style?.color, lightTheme.colorScheme.onSurface);
  });

  testWidgets("dropdown uses light theme colors in light mode",
      (WidgetTester tester) async {
    final ThemeData lightTheme = await loadTheme(tester, ThemeMode.light);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme,
      home: const MovieListing(movie: themeTestMovie),
    ));
    await tester.pumpAndSettle();

    final DropdownMenu<int> dropdown =
        tester.widget<DropdownMenu<int>>(find.byType(DropdownMenu<int>));
    final DropdownMenuEntry<int> firstEntry =
        dropdown.dropdownMenuEntries.first;
    expect(dropdown.textStyle?.color, lightTheme.colorScheme.onSurface);
    expect(
      dropdown.menuStyle?.backgroundColor?.resolve(<WidgetState>{}),
      lightTheme.colorScheme.surface,
    );
    expect(
      firstEntry.style?.foregroundColor?.resolve(<WidgetState>{}),
      lightTheme.colorScheme.onSurface,
    );
  });
}
