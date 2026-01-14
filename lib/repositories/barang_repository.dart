import '../database/db_helper.dart';
import '../models/barang.dart';

class BarangRepository {
  Future<List<Barang>> getAllBarang() async {
    final db = await DBHelper.database;
    final result = await db.query('barang', orderBy: 'id DESC');
    return result.map((e) => Barang.fromMap(e)).toList();
  }

  Future<void> insertBarang(Barang barang) async {
    final db = await DBHelper.database;
    await db.insert('barang', barang.toMap());
  }

  Future<void> updateBarang(Barang barang) async {
    final db = await DBHelper.database;
    await db.update(
      'barang',
      barang.toMap(),
      where: 'id = ?',
      whereArgs: [barang.id],
    );
  }

  Future<void> deleteBarang(int id) async {
    final db = await DBHelper.database;
    await db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Barang>> searchBarang(String keyword) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'barang',
      where: 'nama LIKE ? OR kategori LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return result.map((e) => Barang.fromMap(e)).toList();
  }
}
