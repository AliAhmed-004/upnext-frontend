import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

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
        user_id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        full_name TEXT,
        email TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        latitude REAL,
        longitude REAL
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

  // Insert a new user (uses replace if user already exists)
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'user',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update user data
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'user',
      user,
      where: 'user_id = ?',
      whereArgs: [user['user_id']],
    );
  }

  // Logout: Remove user from database
  Future<void> logout() async {
    final db = await database;
    await db.delete('user');
  }

  // Get all users from database
  Future<List<Map<String, dynamic>>> getUsers() async {
    debugPrint("Fetching users from database...");
    final db = await database;
    return await db.query('user');
  }
}
