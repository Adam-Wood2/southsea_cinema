import 'movie.dart';

class CartItem {
  final Movie movie;
  final int quantity;

  const CartItem({required this.movie, required this.quantity});

  double get lineTotal {
    return movie.price * quantity;
  }
}
