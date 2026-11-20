import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';

void main() {
  const BookingItem item = BookingItem(
    id: null,
    bookingId: 7,
    movieId: "movie-1",
    movieName: "Dracula",
    unitPrice: 11.99,
    quantity: 2,
  );

  test("A booking item links to its parent booking", () {
    expect(item.bookingId, 7);
  });

  test("A new booking item converts to a database map", () {
    expect(item.toMap(), <String, Object?>{
      "bookingId": 7,
      "movieId": "movie-1",
      "movieName": "Dracula",
      "unitPrice": 11.99,
      "quantity": 2,
    });
  });

  test("A database row map converts back into a booking item", () {
    final Map<String, Object?> row = <String, Object?>{
      "id": 3,
      "bookingId": 7,
      "movieId": "movie-1",
      "movieName": "Dracula",
      "unitPrice": 12,
      "quantity": 2,
    };

    final BookingItem restored = BookingItem.fromMap(row);
    expect(restored.id, 3);
    expect(restored.bookingId, 7);
    expect(restored.movieId, "movie-1");
    expect(restored.movieName, "Dracula");
    expect(restored.unitPrice, 12.0);
    expect(restored.quantity, 2);
  });

  test("A parent booking can contain linked booking items", () {
    const Booking booking = Booking(
      id: 7,
      bookingNumber: 8,
      summary: "2 x Dracula",
      total: 23.98,
      date: "20/11/2026 12:00",
      items: <BookingItem>[item],
    );

    expect(booking.items.length, 1);
    expect(booking.items[0].bookingId, booking.id);
  });
}
