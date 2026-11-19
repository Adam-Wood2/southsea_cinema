import 'package:southsea_cinema/models/cart_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

const Movie movie = Movie(
    id: "movie1",
    name: "Movie1",
    releaseYear: 2000,
    ageRating: "PG",
    description: "description",
    price: 10.0,
    date: "date",
    time: "time",
    imagePath: "imagePath");

void main() {
  group("CartItem model test", () {
    test("Creates a cart item instance with given properties", () {
      const CartItem item = CartItem(movie: movie, quantity: 2);

      expect(item.movie, movie);
    });

    test("lineTotal returns the correct price for the cart item", () {
      const CartItem item = CartItem(movie: movie, quantity: 3);

      expect(item.lineTotal, 30.0);
    });
  });
}
