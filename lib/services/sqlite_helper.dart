import 'dart:async';
import 'dart:io';
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
        pledgedBy TEXT,
        isPublished INTEGER NOT NULL,
        imageBase64 TEXT
      )
    ''');

    // users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        pfp TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        preferences TEXT,
        deviceToken TEXT NOT NULL
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

  Stream<List<Map<String, dynamic>>> getStream(
    String table,
    String whereClause,
    dynamic whereArg,
  ) async* {
    final db = await database;
    final StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>.broadcast();

    List<Map<String, dynamic>>? lastData; // Store the last fetched data

    // Function to fetch data from the database
    Future<void> fetchData() async {
      if (controller.isClosed) return; // Check if the controller is closed

      final results = await db.query(
        table,
        where: '$whereClause = ?',
        whereArgs: [whereArg],
      );

      // Only add the data to the stream if it has changed
      if (lastData == null || !_dataEquals(lastData!, results)) {
        lastData = results; // Update the last data
        if (!controller.isClosed) {
          controller.add(results); // Add data to the stream
        }
      }
    }

    // Polling the database every 1 second
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!controller.isClosed) {
        await fetchData(); // Re-fetch data periodically
      }
    });

    // Fetch initial data when the stream starts
    controller.onListen = () async {
      await fetchData(); // Fetch data initially
    };

    // Handle cancellation of the stream
    controller.onCancel = () async {
      await controller.close(); // Close the controller when canceled
    };

    // Yield the stream to the caller
    yield* controller.stream;
  }

  // Helper function to compare two lists of maps
  bool _dataEquals(
      List<Map<String, dynamic>> data1, List<Map<String, dynamic>> data2) {
    if (data1.length != data2.length) return false;
    for (int i = 0; i < data1.length; i++) {
      if (data1[i].length != data2[i].length) return false;
      for (var key in data1[i].keys) {
        if (data1[i][key] != data2[i][key]) return false;
      }
    }
    return true;
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

  // user functions
  // Insert user
  Future<void> insertUser(String id, String name, String pfp, String email,
      String phoneNumber, String? preferencesJson, String? deviceToken) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': id,
        'name': name,
        'pfp': pfp,
        'email': email,
        'phoneNumber': phoneNumber,
        'preferences': preferencesJson ?? '',
        'deviceToken': deviceToken,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update user
  Future<void> updateUser(String id, String? name, String? pfp, String? email,
      String? phoneNumber, String? preferencesJson, String? deviceToken) async {
    final db = await database;
    Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (pfp != null) updateData['pfp'] = pfp;
    if (email != null) updateData['email'] = email;
    if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
    if (preferencesJson != null) updateData['preferences'] = preferencesJson;
    if (deviceToken != null) updateData['deviceToken'] = deviceToken;

    await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to delete the database file permanently
  Future<void> deleteDatabaseFile() async {
    try {
      // Get the path to the database
      String path = join(await getDatabasesPath(), 'hedieaty.db');

      // Create a File instance
      File databaseFile = File(path);

      // Check if the file exists
      if (await databaseFile.exists()) {
        // Delete the file
        await databaseFile.delete();
        print('Database file deleted successfully!');
      } else {
        print('Database file does not exist.');
      }
    } catch (e) {
      print('Error deleting database file: $e');
    }
  }
}