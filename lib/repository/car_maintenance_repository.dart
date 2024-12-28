import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/car_maintenance_record.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class CarMaintenanceRepository {
  static final CarMaintenanceRepository _instance =
      CarMaintenanceRepository._internal();
  static Database? _database;
  static final apiUrl = 'http://192.168.100.10:5129/api';

  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://192.168.100.10:5129/ws'));

  factory CarMaintenanceRepository() {
    return _instance;
  }

  CarMaintenanceRepository._internal() {
    _channel.stream.listen((message) {
      // Handle incoming messages
      final data = jsonDecode(message);
      _handleServerUpdate(data);
    });
  }

  Stream<dynamic> get updatesStream => _channel.stream;

  void _handleServerUpdate(Map<String, dynamic> data) async {
    final db = await database;
    switch (data['action']) {
      case 'add':
        await db.insert(
          'car_maintenance_records',
          CarMaintenanceRecord.fromMap(data['record']).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        break;
      case 'update':
        await db.update(
          'car_maintenance_records',
          CarMaintenanceRecord.fromMap(data['record']).toMap(),
          where: 'id = ?',
          whereArgs: [data['record']['id']],
        );
        break;
      case 'delete':
        await db.delete(
          'car_maintenance_records',
          where: 'id = ?',
          whereArgs: [data['record']['id']],
        );
        break;
    }
  }

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
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE car_maintenance_records(id INTEGER PRIMARY KEY, carModel TEXT, serviceType TEXT, serviceDate TEXT, serviceNotes TEXT)',
        );
      },
      onOpen: (db) async {
        await db.execute('DROP TABLE IF EXISTS car_maintenance_records');
        await db.execute(
          'CREATE TABLE car_maintenance_records(id INTEGER PRIMARY KEY, carModel TEXT, serviceType TEXT, serviceDate TEXT, serviceNotes TEXT)',
        );
      },
    );
  }

  Future<void> insertRecord(CarMaintenanceRecord record) async {
    final db = await database;
    final url = Uri.parse('$apiUrl/CarMaintenanceRecords');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: record.toJson(),
    );

    final serverRecord =
        CarMaintenanceRecord.fromMap(jsonDecode(response.body));
    await db.insert(
      'car_maintenance_records',
      serverRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CarMaintenanceRecord>> refreshRecords() async {
    // Fetch from the local database
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('car_maintenance_records');
    return List.generate(maps.length, (i) {
      return CarMaintenanceRecord.fromMap(maps[i]);
    });

  }


  Future<List<CarMaintenanceRecord>> getRecords() async {
    final db = await database;

    // Perform a one-time fetch from the server
    final response = await http.get(Uri.parse('$apiUrl/CarMaintenanceRecords'));
    if (response.statusCode == 200) {
      final List<dynamic> serverRecords = jsonDecode(response.body);
      for (var record in serverRecords) {
        await db.insert(
          'car_maintenance_records',
          CarMaintenanceRecord.fromMap(record).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } else {
      // Handle error
    }

    // Fetch from the local database
    final List<Map<String, dynamic>> maps =
        await db.query('car_maintenance_records');
    return List.generate(maps.length, (i) {
      return CarMaintenanceRecord.fromMap(maps[i]);
    });
  }

  Future<void> updateRecord(CarMaintenanceRecord record) async {
    final db = await database;
    final url = Uri.parse('$apiUrl/CarMaintenanceRecords/${record.id}');
    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: record.toJson(),
    );

    await db.update(
      'car_maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(int id) async {
    final db = await database;
    final response =
        await http.delete(Uri.parse('$apiUrl/CarMaintenanceRecords/$id'));

    await db.delete(
      'car_maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
