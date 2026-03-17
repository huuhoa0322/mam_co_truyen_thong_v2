import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('mam_co.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        try {
          await db.execute('PRAGMA journal_mode = WAL');
        } catch (_) {}
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Read the SQL file from assets
    final script = await rootBundle.loadString('assets/sql/mam_co.sql');

    // Remove comments
    String cleanScript = script.replaceAll(RegExp(r'--.*'), '');

    // Split script by semicolon to run statements one-by-one
    List<String> statements = cleanScript.split(';');

    for (var statement in statements) {
      final trimmed = statement.trim();
      if (trimmed.isNotEmpty && !trimmed.toUpperCase().startsWith('PRAGMA')) {
        await db.execute(trimmed);
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
