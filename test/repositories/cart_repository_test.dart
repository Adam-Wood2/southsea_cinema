import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/models/movie.dart';

const Movie movie1 = Movie(
    id: "movie1",
    name: "Movie1",
    releaseYear: 2000,
    ageRating: "PG",
    description: "description",
    price: 10.0,
    date: "date",
    time: "time",
    imagePath: "imagePath");

const Movie movie2 = Movie(
    id: "movie2",
    name: "Movie2",
    releaseYear: 2000,
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
  group("Cart repository tests", () {
    test("Starts with empty basket", () {
      final CartRepository cart = CartRepository.instance;

      expect(cart.getItems().length, 0);
      expect(cart.getTotalItems(), 0);
      expect(cart.totalItemCount, 0);
      expect(cart.subtotal, 0.0);
      expect(cart.serviceFee, 0.0);
      expect(cart.totalDue, 0.0);
    });

    test("Adds items and calculates subtotal and service fee correctly", () {
      final CartRepository cart = CartRepository.instance;

      const CartItem item1 = CartItem(movie: movie1, quantity: 2);
      const CartItem item2 = CartItem(movie: movie2, quantity: 1);

      cart.addItem(item1);
      cart.addItem(item2);

      expect(cart.getItems().length, 2);
      expect(cart.getTotalItems(), 3);
      expect(cart.totalItemCount, 3);
      expect(cart.subtotal, 25.0);
      expect(cart.serviceFee, 4.0);
      expect(cart.totalDue, 29.0);
    });

    test("Removes items correctly", () {
      final CartRepository cart = CartRepository.instance;
      const CartItem item = CartItem(movie: movie1, quantity: 3);

      cart.addItem(item);
      expect(cart.getItems().length, 1);

      cart.removeItem(0);
      expect(cart.getItems().length, 0);
      expect(cart.totalDue, 0.0);
    });
  });
}
