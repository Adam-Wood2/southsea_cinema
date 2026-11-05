import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';
import 'package:southsea_cinema/views/basket_view.dart';

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
  setUp(() {
    CartRepository.instance.clear();
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
  });
}
