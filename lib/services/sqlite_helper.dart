import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  static final SQLiteHelper _instance = SQLiteHelper._internal();
  factory SQLiteHelper() => _instance;

  SQLiteHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hedieaty.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        userID TEXT NOT NULL,
        isPublished INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gifts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        eventID TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        isPublished INTEGER NOT NULL
      )
    ''');
  }

  // Insert Data
  Future<void> insertData(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update Data
  Future<void> updateData(
      String table, String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(
      table,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete Data
  Future<void> deleteData(String table, String id) async {
    final db = await database;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch Single Record by ID
  Future<Map<String, dynamic>?> fetchDataById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Fetch Records with Conditions
  Future<List<Map<String, dynamic>>> fetchWhere(
      String table, String whereClause, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  // Get Stream for Real-Time Updates
  Stream<List<Map<String, dynamic>>> getStream(
      String table, String whereClause, dynamic whereArg) async* {
    final db = await database;

    // Periodically emit data from SQLite
    final StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>();

    Future<void> emitData() async {
      final results = await db.query(
        table,
        where: '$whereClause = ?',
        whereArgs: [whereArg],
      );
      controller.add(results);
    }

    // Emit data every second
    Timer.periodic(Duration(seconds: 1), (_) async {
      await emitData();
    });

    controller.onListen = emitData;

    yield* controller.stream;
  }

  // fetch data by column
  Future<List<Map<String, dynamic>>> fetchByColumn(
      String table, String column, dynamic value) async {
    final db = await database;
    return await db.query(
      table,
      where: '$column = ?',
      whereArgs: [value],
    );
  }
}
