import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final Database database =
        await databaseFactoryFfiNoIsolate.openDatabase(inMemoryDatabasePath,
            options: OpenDatabaseOptions(
                version: 2,
                onCreate: CinemaDatabase.instance.createTables,
                onConfigure: (Database database) async {
                  await database.execute("PRAGMA foreign_keys = ON");
                }));
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
    await CinemaDatabase.instance.insertBooking(buildRecord(1, "Order", 1.0));

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

  test("Database creation creates bookings and linked booking_items", () async {
    final Database database = await CinemaDatabase.instance.database;
    final List<Map<String, Object?>> tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    expect(tables.any((Map<String, Object?> row) => row["name"] == "bookings"),
        isTrue);
    expect(
        tables
            .any((Map<String, Object?> row) => row["name"] == "booking_items"),
        isTrue);
  });

  test("Booking and linked items are stored for the same order", () async {
    const Booking booking = Booking(
      bookingNumber: 10,
      summary: "2 x Dracula",
      total: 23.98,
      date: "20/11/2026 12:00",
    );
    const BookingItem item = BookingItem(
      bookingId: 0,
      movieId: "dracula",
      movieName: "Dracula",
      unitPrice: 11.99,
      quantity: 2,
    );

    final int bookingId = await CinemaDatabase.instance.insertBookingWithItems(
      booking,
      <BookingItem>[item],
    );
    final List<BookingItem> items =
        await CinemaDatabase.instance.getBookingItems(bookingId);

    expect(items.length, 1);
    expect(items[0].bookingId, bookingId);
    expect(items[0].movieName, "Dracula");
    expect(items[0].quantity, 2);
  });

  test("An order can be stored without booking items", () async {
    const Booking booking = Booking(
      bookingNumber: 13,
      summary: "No tickets",
      total: 0.0,
      date: "20/11/2026 12:00",
    );

    final int bookingId = await CinemaDatabase.instance
        .insertBookingWithItems(booking, <BookingItem>[]);
    final List<Booking> bookings = await CinemaDatabase.instance.getAllOrders();

    expect(bookingId, greaterThan(0));
    expect(bookings.length, 1);
    expect(bookings[0].id, bookingId);
    expect(bookings[0].summary, "No tickets");
    expect(bookings[0].items, isEmpty);
  });

  test("Foreign key rejects an item for a missing booking", () async {
    final Database database = await CinemaDatabase.instance.database;

    await expectLater(
      database.insert("booking_items", <String, Object?>{
        "bookingId": 999,
        "movieId": "dracula",
        "movieName": "Dracula",
        "unitPrice": 11.99,
        "quantity": 1,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test("A failed linked item rolls back the complete order", () async {
    const Booking booking = Booking(
      bookingNumber: 11,
      summary: "2 x Dracula",
      total: 23.98,
      date: "20/11/2026 12:00",
    );
    const BookingItem validItem = BookingItem(
      bookingId: 0,
      movieId: "dracula",
      movieName: "Dracula",
      unitPrice: 11.99,
      quantity: 1,
    );
    const BookingItem invalidItem = BookingItem(
      bookingId: 0,
      movieId: "train",
      movieName: "Bullet Train",
      unitPrice: 11.99,
      quantity: 0,
    );

    await expectLater(
      CinemaDatabase.instance.insertBookingWithItems(
        booking,
        <BookingItem>[validItem, invalidItem],
      ),
      throwsA(isA<DatabaseException>()),
    );

    final List<Booking> bookings = await CinemaDatabase.instance.getAllOrders();
    expect(bookings, isEmpty);
  });

  test("Deleting a booking cascades and removes linked items", () async {
    const Booking booking = Booking(
      bookingNumber: 12,
      summary: "1 x Dracula",
      total: 11.99,
      date: "20/11/2026 12:00",
    );
    const BookingItem item = BookingItem(
      bookingId: 0,
      movieId: "dracula",
      movieName: "Dracula",
      unitPrice: 11.99,
      quantity: 1,
    );
    final int bookingId = await CinemaDatabase.instance.insertBookingWithItems(
      booking,
      <BookingItem>[item],
    );
    final Database database = await CinemaDatabase.instance.database;

    await database
        .delete("bookings", where: "id = ?", whereArgs: <Object?>[bookingId]);

    expect(await CinemaDatabase.instance.getBookingItems(bookingId), isEmpty);
  });

  test("File migration preserves existing v1 orders", () async {
    final Directory directory =
        await Directory.systemTemp.createTemp("southsea_migration");
    final String filePath = join(directory.path, "cinema_v1.db");
    final Database oldDatabase = await databaseFactoryFfiNoIsolate.openDatabase(
      filePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database database, int version) async {
          await database.execute("""
            CREATE TABLE bookings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              bookingNumber INTEGER NOT NULL,
              summary TEXT NOT NULL,
              total REAL NOT NULL,
              date TEXT NOT NULL
            )
          """);
          await database.insert("bookings", <String, Object?>{
            "bookingNumber": 99,
            "summary": "1 x Old Movie",
            "total": 8.50,
            "date": "01/01/2025 10:00",
          });
        },
      ),
    );
    await oldDatabase.close();

    final Database upgradedDatabase =
        await CinemaDatabase.instance.openDatabaseAtPath(filePath);
    CinemaDatabase.instance.setDatabase(upgradedDatabase);

    final List<Booking> bookings = await CinemaDatabase.instance.getAllOrders();
    expect(bookings.length, 1);
    expect(bookings[0].bookingNumber, 99);
    expect(bookings[0].summary, "1 x Old Movie");
    expect(bookings[0].items, isEmpty);

    await CinemaDatabase.instance.close();
    await directory.delete(recursive: true);
  });
}
