import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHandler {
  static final DBHandler _instance = DBHandler._internal();
  factory DBHandler() => _instance;

  DBHandler._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'favorites.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE favorites (id INTEGER PRIMARY KEY, name TEXT, email TEXT)',
        );
      },
    );
  }

  Future<void> insertFavorite(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'favorites',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  Future<void> deleteFavorite(int id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}
