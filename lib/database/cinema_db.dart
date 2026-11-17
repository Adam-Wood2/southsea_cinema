import 'package:path/path.dart';
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
}
