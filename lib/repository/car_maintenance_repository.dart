import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/car_maintenance_record.dart';

class CarMaintenanceRepository {
  static final CarMaintenanceRepository _instance =
      CarMaintenanceRepository._internal();
  static Database? _database;

  factory CarMaintenanceRepository() {
    return _instance;
  }

  CarMaintenanceRepository._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'car_maintenance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE car_maintenance_records(id INTEGER PRIMARY KEY, carModel TEXT, serviceType TEXT, serviceDate TEXT, serviceNotes TEXT)',
        );
      },
    );
  }

  Future<void> insertRecord(CarMaintenanceRecord record) async {
    final db = await database;
    await db.insert(
      'car_maintenance_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CarMaintenanceRecord>> getRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('car_maintenance_records');
    return List.generate(maps.length, (i) {
      return CarMaintenanceRecord(
        id: maps[i]['id'],
        carModel: maps[i]['carModel'],
        serviceType: maps[i]['serviceType'],
        serviceDate: maps[i]['serviceDate'],
        serviceNotes: maps[i]['serviceNotes'],
      );
    });
  }

  Future<void> updateRecord(CarMaintenanceRecord record) async {
    final db = await database;
    await db.update(
      'car_maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete(
      'car_maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
