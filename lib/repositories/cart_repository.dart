import 'package:southsea_cinema/models/cart_item.dart';

class CartRepository {
  CartRepository._internal();

  static final CartRepository instance = CartRepository._internal();

  final List<CartItem> _items = [];

  List<CartItem> getItems() {
    return List<CartItem>.unmodifiable(_items);
  }

  void addItem(CartItem item) {
    _items.add(item);
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  int getTotalItems() {
    int total = 0;
    for (final CartItem item in _items) {
      total += item.quantity;
    }
    return total;
  }

  int get totalItemCount {
    return getTotalItems();
  }

  double getSubtotal() {
    double sum = 0.0;
    for (final CartItem item in _items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  double getServiceFee() {
    if (_items.isEmpty) {
      return 0.0;
    } else {
      return 4.0;
    }
  }

  double getTotalDue() {
    return getSubtotal() + getServiceFee();
  }

  double get subtotal {
    return getSubtotal();
  }

  double get serviceFee {
    return getServiceFee();
  }

  double get totalDue {
    return getTotalDue();
  }

  void clear() {
    _items.clear();
  }
}
