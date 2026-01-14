import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/barang.dart';

class BarangRepository {
  final dbHelper = DBHelper.instance;

  Future<List<Barang>> getAllBarang() async {
    final db = await dbHelper.database;
    final result = await db.query('barang', orderBy: 'nama ASC');
    return result.map((e) => Barang.fromMap(e)).toList();
  }

  Future<int> insertBarang(Barang barang) async {
    final db = await dbHelper.database;
    return await db.insert('barang', barang.toMap());
  }

  Future<int> updateBarang(Barang barang) async {
    final db = await dbHelper.database;
    return await db.update(
      'barang',
      barang.toMap(),
      where: 'id = ?',
      whereArgs: [barang.id],
    );
  }

  Future<int> deleteBarang(int id) async {
    final db = await dbHelper.database;
    return await db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Barang>> searchBarang(String keyword) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'barang',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
    );
    return result.map((e) => Barang.fromMap(e)).toList();
  }
}
