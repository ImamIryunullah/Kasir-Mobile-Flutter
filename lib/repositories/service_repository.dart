import '../database/db_helper.dart';
import '../models/service.dart';
import 'package:sqflite/sqflite.dart';

class ServiceRepository {
  Future<List<Service>> getAllService() async {
    final db = await DBHelper.database;
    final result = await db.query('service', orderBy: 'id DESC');
    return result.map((e) => Service.fromMap(e)).toList();
  }

  Future<void> insertService(Service service) async {
    final db = await DBHelper.database;
    await db.insert('service', service.toMap());
  }

  Future<void> updateService(Service service) async {
    final db = await DBHelper.database;
    await db.update(
      'service',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<void> deleteService(int id) async {
    final db = await DBHelper.database;
    await db.delete('service', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Service>> searchService(String keyword) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'service',
      where: 'pelanggan LIKE ? OR mesin LIKE ? OR lokasi LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((e) => Service.fromMap(e)).toList();
  }

  Future<List<Service>> getServiceByStatus(String status) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'service',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC',
    );
    return result.map((e) => Service.fromMap(e)).toList();
  }

  // Get total revenue from completed services
  Future<int> getTotalRevenue() async {
    final db = await DBHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(biaya) as total FROM service WHERE status = ?',
      ['Selesai'],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  // Get count of services by status
  Future<int> getCountByStatus(String status) async {
    final db = await DBHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM service WHERE status = ?',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
