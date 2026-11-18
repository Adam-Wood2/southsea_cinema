import 'package:path/path.dart';
import 'package:southsea_cinema/models/booking.dart';
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
    final Database db = await openDatabase(
      filePath,
      version: 1,
      onCreate: _createDB,
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
  }

  Future<void> _createDB(Database db, int version) async {
    await createTables(db, version);
    await db.insert("bookings", <String, Object?>{
      "bookingNumber": 1,
      "summary": "1 x Dracula",
      "total": 11.99,
      "date": "Thursday 22nd October"
    });

    await db.insert("bookings", <String, Object?>{
      "bookingNumber": 2,
      "summary": "2 x Dracula",
      "total": 19.98,
      "date": "Thursday 22nd October"
    });

    await db.insert("bookings", <String, Object?>{
      "bookingNumber": 3,
      "summary": "3 x Bullet Train",
      "total": 34.00,
      "date": "Thursday 22nd October"
    });
  }

  Future<int> insertBooking(Booking booking) async {
    final Database db = await database;
    final int id = await db.insert("bookings", booking.toMap());
    return id;
  }

  Future<List<Booking>> getAllOrders() async {
    final Database db = await database;
    final List<Map<String, Object?>> records =
        await db.query("bookings", orderBy: "bookingNumber DESC");
    final List<Booking> bookings = [];

    for (final Map<String, Object?> row in records) {
      bookings.add(Booking.fromMap(row));
    }
    return bookings;
  }

  Future<int> getNextOrderNumber() async {
    final Database db = await database;
    final List<Map<String, Object?>> records =
        await db.rawQuery("SELECT MAX(bookingNumber) as maxNum FROM orders");

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
