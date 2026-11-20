import 'package:path/path.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';
import 'package:sqflite/sqflite.dart';

class CinemaDatabase {
  CinemaDatabase._internal();

  static final CinemaDatabase instance = CinemaDatabase._internal();

  static Database? _database;

  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> get database async {
    final Database? cachedDatabase = _database;
    if (cachedDatabase != null) {
      return cachedDatabase;
    }
    final Database db = await _initDB("cinema_data.db");
    _database = db;
    return db;
  }

  Future<Database> _initDB(String fileName) async {
    final String folder = await getDatabasesPath();
    final String filePath = join(folder, fileName);
    return await openDatabaseAtPath(filePath);
  }

  Future<Database> openDatabaseAtPath(String filePath) async {
    final Database db = await openDatabase(
      filePath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await createTables(db, newVersion);
      },
      onConfigure: (Database db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
    );

    return db;
  }

  Future<void> createTables(Database db, int version) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bookingNumber INTEGER NOT NULL,
      summary TEXT NOT NULL,
      total REAL NOT NULL,
      date TEXT NOT NULL
      )
  """);
    await db.execute("""
      CREATE TABLE IF NOT EXISTS booking_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bookingId INTEGER NOT NULL,
      movieId TEXT NOT NULL,
      movieName TEXT NOT NULL,
      unitPrice REAL NOT NULL,
      quantity INTEGER NOT NULL CHECK (quantity > 0),
      FOREIGN KEY (bookingId) REFERENCES bookings(id)
        ON DELETE CASCADE
      )
  """);
  }

  Future<void> _createDB(Database db, int version) async {
    await createTables(db, version);
    await db.transaction((Transaction transaction) async {
      await transaction.insert("bookings", <String, Object?>{
        "bookingNumber": 1,
        "summary": "1 x Dracula",
        "total": 11.99,
        "date": "Thursday 22nd October"
      });

      await transaction.insert("bookings", <String, Object?>{
        "bookingNumber": 2,
        "summary": "2 x Dracula",
        "total": 19.98,
        "date": "Thursday 22nd October"
      });

      await transaction.insert("bookings", <String, Object?>{
        "bookingNumber": 3,
        "summary": "3 x Bullet Train",
        "total": 34.00,
        "date": "Thursday 22nd October"
      });
    });
  }

  Future<int> insertBooking(Booking booking) async {
    final Database db = await database;
    return await db.transaction((Transaction transaction) async {
      return await transaction.insert("bookings", booking.toMap());
    });
  }

  Future<int> insertBookingWithItems(
      Booking booking, List<BookingItem> items) async {
    final Database db = await database;
    return await db.transaction((Transaction transaction) async {
      final int bookingId =
          await transaction.insert("bookings", booking.toMap());

      for (final BookingItem item in items) {
        final BookingItem linkedItem = BookingItem(
          bookingId: bookingId,
          movieId: item.movieId,
          movieName: item.movieName,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
        );
        await transaction.insert("booking_items", linkedItem.toMap());
      }

      return bookingId;
    });
  }

  Future<List<BookingItem>> getBookingItems(int bookingId) async {
    final Database db = await database;
    final List<Map<String, Object?>> records = await db.query(
      "booking_items",
      where: "bookingId = ?",
      whereArgs: <Object?>[bookingId],
      orderBy: "id ASC",
    );

    final List<BookingItem> items = <BookingItem>[];
    for (final Map<String, Object?> row in records) {
      items.add(BookingItem.fromMap(row));
    }
    return items;
  }

  Future<List<Booking>> getAllOrders() async {
    final Database db = await database;
    final List<Map<String, Object?>> records =
        await db.query("bookings", orderBy: "bookingNumber DESC");
    final List<Booking> bookings = [];

    for (final Map<String, Object?> row in records) {
      final Booking booking = Booking.fromMap(row);

      final List<BookingItem> items = await getBookingItems(booking.id as int);
      bookings.add(Booking(
        id: booking.id,
        bookingNumber: booking.bookingNumber,
        summary: booking.summary,
        total: booking.total,
        date: booking.date,
        items: items,
      ));
    }
    return bookings;
  }

  Future<int> getNextOrderNumber() async {
    final Database db = await database;
    final List<Map<String, Object?>> records =
        await db.rawQuery("SELECT MAX(bookingNumber) as maxNum FROM bookings");

    if (records.isEmpty) {
      return 1;
    }

    final Object? maxValue = records[0]["maxNum"];
    if (maxValue == null) {
      return 1;
    }
    final int currentMax = maxValue as int;
    return currentMax + 1;
  }

  Future<void> close() async {
    final Database? cachedDatabase = _database;
    if (cachedDatabase != null) {
      await cachedDatabase.close();
      _database = null;
    }
  }
}
