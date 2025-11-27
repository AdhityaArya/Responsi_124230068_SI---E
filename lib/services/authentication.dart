// lib/services/authentication.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/makanan.dart'; // Import Restaurant model

// --- 1. Database Helper (Local Database untuk Favorit) ---
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal() {
    _instance = this;
  }

  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  static const String _tblFavorite = 'favorites';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'restaurant_app.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE $_tblFavorite (
             id TEXT PRIMARY KEY,
             name TEXT,
             description TEXT,
             pictureId TEXT,
             city TEXT,
             rating REAL
           )''');
      },
      version: 1,
    );
    return db;
  }

  Future<Database?> get database async {
    _database ??= await _initializeDb();
    return _database;
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db!.insert(
      _tblFavorite,
      restaurant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(_tblFavorite);

    return List.generate(maps.length, (i) {
      return Restaurant.fromMap(maps[i]);
    });
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db!.delete(_tblFavorite, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map> getFavoriteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(
      _tblFavorite,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return {};
    }
  }
}

// --- 2. Shared Preferences Helper (untuk Login/Register) ---
class AuthPreferenceHelper {
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Menyimpan data login
  Future<void> saveLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Mendapatkan username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Mengecek status login
  Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Melakukan logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Simulasi Register
  Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan data login sederhana
    await prefs.setString('user_$username', password);
    return true;
  }

  // Simulasi Login
  Future<bool> checkLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('user_$username');

    if (storedPassword == password && storedPassword != null) {
      await saveLogin(username);
      return true;
    }
    return false;
  }
}
