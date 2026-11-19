import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/cart_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/square_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() {
    return _BasketViewState();
  }
}

class _BasketViewState extends State<BasketView> {
  String _confirmationMessage = "";
  String _errorMessage = "";
  List<Booking> _bookings = [];

  String _formatDate(DateTime now) {
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/${now.year} $hour:$minute';
  }

  String _buildSummary(List<CartItem> items) {
    final List<String> parts = [];
    for (final CartItem item in items) {
      parts.add("${item.quantity} x ${item.movie.name}");
    }
    return parts.join(", ");
  }

  Future<void> _checkout(CartRepository cart, List<CartItem> items) async {
    final double total = cart.totalDue;
    final String date = _formatDate(DateTime.now());
    final String summary = _buildSummary(items);

    try {
      final CinemaDatabase database = CinemaDatabase.instance;
      final int bookingNumber = await database.getNextOrderNumber();
      final Booking record = Booking(
          bookingNumber: bookingNumber,
          summary: summary,
          total: total,
          date: date);
      await database.insertBooking(record);
      List<Booking> updatedBookings =
          await CinemaDatabase.instance.getAllOrders();
      cart.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = updatedBookings;
        _confirmationMessage = "Booking $bookingNumber saved";
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = "Could not save your booking: $error";
      });
    }
  }

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
                icon: Icon(Icons.delete_outline, key: Key(index.toString())),
                onPressed: () {
                  setState(() {
                    cart.removeItem(index);
                  });
                })
          ],
        ));
  }

  Widget _buildTotalRow(String label, String value, {bool emphasise = false}) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final TextStyle style;
    if (emphasise) {
      style = TextStyle(
          color: textColor, fontWeight: FontWeight.bold, fontSize: 16);
    } else {
      style = listingDescriptionStyle.copyWith(color: textColor);
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label, style: style), Text(value, style: style)],
        ));
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllOrders();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = bookings;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = "Unable to load bookings: $_errorMessage";
      });
    }
  }

  Card _buildBookingCard(Booking booking) {
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    return Card(
      color: surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${booking.bookingNumber}"),
                Text("£${booking.total.toStringAsFixed(2)}")
              ],
            ),
            const SizedBox(height: 4),
            Text(booking.summary),
            const SizedBox(height: 4),
            Text(booking.date)
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsRows() {
    final Widget body;
    if (_errorMessage.isNotEmpty) {
      body = Center(child: Text(_errorMessage));
    } else if (_bookings.isEmpty) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text("No bookings yet"),
        ),
      );
    } else {
      body = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _bookings.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildBookingCard(_bookings[index]);
        },
      );
    }
    return body;
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
              _checkout(cart, items);
            })));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final CartRepository cart = CartRepository.instance;
    final List<CartItem> items = cart.getItems();
    final Widget content;
    final Widget body = _buildBookingsRows();

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
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [content, body],
          ),
        ));
  }
}
