import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the database
    _database = await _initDatabase('upnext_database.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$fileName';
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        full_name TEXT,
        email TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE listing (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES user (user_id) ON DELETE CASCADE
      )
    ''');
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // delete the database
  Future<void> deleteDatabaseFile(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$fileName';
    await deleteDatabase(path);
  }

  // ==================================================================
  // USER METHODS
  // ==================================================================

  // Insert a new user
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('user', user);
  }

  // Logout: Remove user from database
  Future<void> logout() async {
    final db = await database;
    await db.delete('user');
  }

  // Get all users from database
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('user');
  }

  // ==================================================================
  // LISTING METHODS
  // ==================================================================

  // Insert a batch of listings
  Future<void> insertListings(List<Map<String, dynamic>> listings) async {
    final db = await database;

    final batch = db.batch();
    for (var item in listings) {
      batch.insert(
        'Listing',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Get all listings from database
  Future<List<Map<String, dynamic>>> getListings() async {
    final db = await database;
    return await db.query('listing');
  }
}
