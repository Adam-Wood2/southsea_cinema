import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/widgets/square_button.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
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

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() {
    return _BasketViewState();
  }
}

class _BasketViewState extends State<BasketView> {
  String _confirmationMessage = "";

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Text("Your basket is empty",
              style: TextStyle(fontSize: 16, color: Colors.grey))),
    );
  }

  Widget _buildLineItem(CartRepository cart, CartItem item, int index) {
    Movie itemMovie = item.movie;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.quantity > 1
                        ? "${item.quantity} tickets"
                        : "${item.quantity} ticket"),
                    Text("£${item.lineTotal.toStringAsFixed(2)}")
                  ],
                )),
            Expanded(
                flex: 8,
                child: Text(
                    "${itemMovie.name}, ${itemMovie.date}, ${itemMovie.time}",
                    textAlign: TextAlign.left)),
            IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    cart.removeItem(index);
                  });
                })
          ],
        ));
  }

  Widget _buildTotalRow(String label, String value, {bool emphasise = false}) {
    final TextStyle style;
    if (emphasise) {
      style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    } else {
      style = listingDescriptionStyle;
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: style), Text(value, style: style)],
        ));
  }

  Widget _buildBasketList(CartRepository cart, List<CartItem> items) {
    final List<Widget> children = [];
    children.add(Text("My Order",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
    children.add(SizedBox(height: 12));
    children.add(Row(
      children: [
        Expanded(flex: 2, child: Text("Item")),
        Expanded(flex: 8, child: Text("Details"))
      ],
    ));

    for (int index = 0; index < items.length; index++) {
      final CartItem item = items[index];
      children.add(_buildLineItem(cart, item, index));
    }

    children.add(const SizedBox(height: 24));
    children.add(
      _buildTotalRow(
        'Items subtotal',
        '£${cart.subtotal.toStringAsFixed(2)}',
      ),
    );
    children.add(
      _buildTotalRow(
        'Delivery',
        '£${cart.serviceFee.toStringAsFixed(2)}',
      ),
    );
    children.add(
      _buildTotalRow(
        'Total to pay',
        '£${cart.totalDue.toStringAsFixed(2)}',
        emphasise: true,
      ),
    );
    children.add(const SizedBox(height: 24));

    children.add(SizedBox(
        width: double.infinity,
        child: SquareButton(
            label: "Checkout",
            onPressed: () {
              setState(() {
                cart.clear();
                _confirmationMessage = "Tickets successfully purchased";
              });
            })));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartRepository cart = CartRepository.instance;
    final List<CartItem> items = cart.getItems();
    final Widget content;

    if (items.isEmpty) {
      if (_confirmationMessage.isNotEmpty) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmptyState(),
            const SizedBox(height: 12),
            Center(child: Text(_confirmationMessage))
          ],
        );
      } else {
        content = _buildEmptyState();
      }
    } else {
      content = _buildBasketList(cart, items);
    }

    return Scaffold(
        appBar: AppBar(title: const Text(appTitle)),
        drawer: const NavDrawer(),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0), child: content));
  }
}
