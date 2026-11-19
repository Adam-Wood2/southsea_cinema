import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void main() {
  setUp(() async {
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

  Booking buildRecord(int bookingNumber, String summary, double total) {
    return Booking(
        bookingNumber: bookingNumber,
        summary: summary,
        total: total,
        date: "01/01/2026 10:00");
  }

  test("insertBooking stores an order and returns its id", () async {
    final int id = await CinemaDatabase.instance
        .insertBooking(buildRecord(1001, "1 x ticket", 7.5));

    expect(id, greaterThan(0));
    final List<Booking> bookings = await CinemaDatabase.instance.getAllOrders();
    expect(bookings.length, 1);
    expect(bookings[0].id, id);
    expect(bookings[0].summary, "1 x ticket");
    expect(bookings[0].total, 7.50);
  });

  test("getNextBookingNumber increments the current number", () async {
    expect(await CinemaDatabase.instance.getNextOrderNumber(), 1);

    await CinemaDatabase.instance.insertBooking(buildRecord(5, "Order", 1.0));

    expect(await CinemaDatabase.instance.getNextOrderNumber(), 6);
  });

  test("getAllBookings returns newest order number first", () async {
    await CinemaDatabase.instance.insertBooking(buildRecord(1, "First", 1.0));
    await CinemaDatabase.instance.insertBooking(buildRecord(3, "Third", 3.0));
    await CinemaDatabase.instance.insertBooking(buildRecord(2, "Second", 2.0));
    final List<Booking> bookings = await CinemaDatabase.instance.getAllOrders();

    expect(bookings[0].bookingNumber, 3);
    expect(bookings[1].bookingNumber, 2);
    expect(bookings[2].bookingNumber, 1);
  });
}
