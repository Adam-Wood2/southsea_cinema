import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

const Movie testMovie = Movie(
    id: "id",
    name: "name",
    releaseYear: 1999,
    ageRating: "PG",
    description: "description",
    price: 10.0,
    date: "date",
    time: "time",
    imagePath: "imagePath");

const Movie testMovie2 = Movie(
    id: "id2",
    name: "name2",
    releaseYear: 1999,
    ageRating: "PG",
    description: "description",
    price: 5.0,
    date: "date",
    time: "time",
    imagePath: "imagePath");

void main() {
  setUp(() async {
    rootBundle.clear();
    CartRepository.instance.clear();
    sqfliteFfiInit();
    final Database database = await databaseFactoryFfiNoIsolate.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 1, onCreate: CinemaDatabase.instance.createTables));
    CinemaDatabase.instance.setDatabase(database);
  });

  tearDown(() async {
    await CinemaDatabase.instance.close();
  });
  group("BasketView tests", () {
    testWidgets(
        "BasketView displays empty message when basket repository is empty",
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BasketView()));

      expect(find.text("Your basket is empty"), findsOneWidget);
      expect(find.text("Checkout"), findsNothing);
    });

    testWidgets(
        "BasketView renders items and removes items when delete is pressed",
        (WidgetTester tester) async {
      const CartItem item = CartItem(movie: testMovie, quantity: 3);
      CartRepository.instance.addItem(item);

      await tester.pumpWidget(const MaterialApp(home: BasketView()));

      expect(find.text("My Order"), findsOneWidget);
      expect(find.text("3 tickets"), findsOneWidget);
      expect(find.text("£30.00").first, findsOneWidget);
      expect(find.textContaining("name"), findsOneWidget);
      expect(find.text("Checkout"), findsOneWidget);
      expect(find.text("Your basket is empty"), findsNothing);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.text("Your basket is empty"), findsOneWidget);
    });

    testWidgets("BasketView displays correct total",
        (WidgetTester tester) async {
      const CartItem item = CartItem(movie: testMovie, quantity: 2);
      const CartItem item2 = CartItem(movie: testMovie2, quantity: 3);
      CartRepository.instance.addItem(item);
      CartRepository.instance.addItem(item2);

      await tester.pumpWidget(const MaterialApp(home: BasketView()));

      expect(find.text("£20.00"), findsOneWidget);
      expect(find.text("£15.00"), findsOneWidget);
      expect(find.text("£35.00"), findsOneWidget);
      expect(find.text("£4.00"), findsOneWidget);
      expect(find.text("£39.00"), findsOneWidget);
    });

    testWidgets("Items loaded from JSON are added to the basket correctly",
        (WidgetTester tester) async {
      MovieRepository repository = MovieRepository();
      final List<Movie> movies = await repository.loadMoviesFromAsset();

      CartItem item = CartItem(movie: movies[2], quantity: 3);
      CartRepository.instance.addItem(item);

      await tester.pumpWidget(const MaterialApp(home: BasketView()));

      expect(find.text("3 tickets"), findsOneWidget);
      expect(find.textContaining("Bullet Train"), findsOneWidget);
      expect(find.text("£30.00").last, findsOneWidget);
      expect(find.text("£34.00"), findsOneWidget);
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

    testWidgets("deleting middle basket line keeps other two",
        (WidgetTester tester) async {
      CartRepository.instance.addItem(CartItem(movie: testMovie, quantity: 1));
      CartRepository.instance.addItem(CartItem(movie: testMovie, quantity: 2));
      CartRepository.instance.addItem(CartItem(movie: testMovie2, quantity: 3));

      await tester.pumpWidget(MaterialApp(home: BasketView()));
      await tester.pumpAndSettle();

      expect(find.byKey(Key("1")), findsOneWidget);
      await tester.tap(find.byKey(Key("1")));

      final List<CartItem> items = CartRepository.instance.getItems();
      expect(items.length, 2);
      expect(items[0].movie.name, "name");
      expect(items[0].quantity, 1);
      expect(items[1].movie.name, "name2");
      expect(items[1].quantity, 3);
    });
  });

  group("Basket checkout tests", () {
    testWidgets(
        "Checkout saves the order, clears the basket, and displays the booking card",
        (WidgetTester tester) async {
      CartRepository.instance
          .addItem(const CartItem(movie: testMovie, quantity: 2));
      await tester.pumpWidget(MaterialApp(home: BasketView()));

      await tester.runAsync(() async {
        await tester.tap(find.text("Checkout"));
        await tester.pumpAndSettle();
      });
      await tester.pumpAndSettle();

      final List<Booking>? bookings = await tester.runAsync(() async {
        return await CinemaDatabase.instance.getAllOrders();
      });

      expect(bookings, isNotNull);
      if (bookings != null) {
        expect(bookings.length, 1);
        expect(bookings[0].bookingNumber, 1);
        expect(bookings[0].summary, "2 x name");
        expect(bookings[0].total, 24.0);
      }
      expect(CartRepository.instance.getItems(), isEmpty);
      expect(find.text("Order #1"), findsOneWidget);
    });

    testWidgets("Checkout keeps the basket when saving failts",
        (WidgetTester tester) async {
      CartRepository.instance
          .addItem(const CartItem(movie: testMovie, quantity: 2));

      await tester.runAsync(() async {
        final Database database = await CinemaDatabase.instance.database;
        await database.execute("DROP TABLE bookings");
      });

      await tester.pumpWidget(MaterialApp(home: BasketView()));
      await tester.runAsync(() async {
        await tester.tap(find.text("Checkout"));
        await tester.pumpAndSettle();
      });
      await tester.pumpAndSettle();

      expect(CartRepository.instance.getItems().length, 1);
      expect(find.text("2 tickets"), findsOneWidget);
      expect(
          find.textContaining("Could not save your booking"), findsOneWidget);
    });
  });

  group("Bookings list tests", () {
    testWidgets("Displays saved orders newest first",
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await CinemaDatabase.instance.insertBooking(const Booking(
            bookingNumber: 1,
            summary: "1 x Movie",
            total: 4.5,
            date: "01/01/2000 10:00"));

        await CinemaDatabase.instance.insertBooking(const Booking(
            bookingNumber: 2,
            summary: "1 x Movie2",
            total: 5.5,
            date: "02/01/2000 10:00"));

        await tester.pumpWidget(MaterialApp(home: BasketView()));
        await tester.pumpAndSettle();
      });

      await tester.pump();
      expect(find.text("Order #2"), findsOneWidget);
      expect(find.text("Order #1"), findsOneWidget);
      expect(find.text("1 x Movie2"), findsOneWidget);
      final double newestY = tester.getTopLeft(find.text("Order #2")).dy;
      final double oldestY = tester.getTopLeft(find.text("Order #1")).dy;
      expect(newestY, lessThan(oldestY));
    });

    testWidgets("Shows an empty booking list when there are no bookings",
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(home: BasketView()));
        await tester.pumpAndSettle();
      });
      tester.pump;

      expect(find.text("No bookings yet"), findsOneWidget);
    });
  });
}
