import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  const Booking booking = Booking(
      bookingNumber: 1,
      summary: "2 x Dracula",
      total: 10.99,
      date: "Wednesday 21st October");

  test("New bookings omit database ids and convert to map", () {
    expect(booking.id, isNull);
    expect(booking.toMap(), <String, Object?>{
      "bookingNumber": 1,
      "summary": "2 x Dracula",
      "total": 10.99,
      "date": "Wednesday 21st October"
    });
  });

  test("A database row map converts back into a booking object", () {
    final Map<String, Object?> row = <String, Object?>{
      "id": 2,
      "bookingNumber": 2,
      "summary": "1 x Dracula",
      "total": 11.99,
      "date": "Thursday 22nd October"
    };

    final Booking rowToBooking = Booking.fromMap(row);
    expect(rowToBooking.id, 2);
    expect(rowToBooking.bookingNumber, 2);
    expect(rowToBooking.summary, "1 x Dracula");
    expect(rowToBooking.total, 11.99);
    expect(rowToBooking.date, "Thursday 22nd October");
    expect(rowToBooking.toMap(), row);
  });

  test("Whole numbers in SQLite rows becoming doubles", () {
    final Map<String, Object?> row = booking.toMap();
    row["total"] = 5;
    final Booking restored = Booking.fromMap(row);
    expect(restored.total, 5.0);
    expect(restored.total, isA<double>());
  });
}
