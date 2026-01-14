import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'kasir.db');

    return openDatabase(
      path,
      version: 2, // Increment version untuk migrasi
      onCreate: (db, version) async {
        // Tabel Barang
        await db.execute('''
          CREATE TABLE barang (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            harga INTEGER,
            stok INTEGER,
            kategori TEXT
          )
        ''');

        // Tabel Service
        await db.execute('''
          CREATE TABLE service (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pelanggan TEXT,
            mesin TEXT,
            lokasi TEXT,
            biaya INTEGER,
            status TEXT,
            tanggal TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migrasi dari versi 1 ke 2: tambah tabel service
          await db.execute('''
            CREATE TABLE IF NOT EXISTS service (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              pelanggan TEXT,
              mesin TEXT,
              lokasi TEXT,
              biaya INTEGER,
              status TEXT,
              tanggal TEXT
            )
          ''');
        }
      },
    );
  }
}
