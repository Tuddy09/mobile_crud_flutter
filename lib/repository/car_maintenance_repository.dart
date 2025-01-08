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

  late WebSocketChannel _channel;
  late StreamSubscription _streamSubscription;

  factory CarMaintenanceRepository() {
    return _instance;
  }

  CarMaintenanceRepository._internal() {
    initializeWebSocket();
  }

  void initializeWebSocket() {
    print('Initializing WebSocket...');
    _channel =
        WebSocketChannel.connect(Uri.parse('ws://192.168.100.10:5129/ws'));
    _streamSubscription = _channel.stream.listen(
        (message) {
          // Handle incoming messages
          final data = jsonDecode(message);
          _handleServerUpdate(data);
        },
        onDone: _clean,
        onError: (error) {
          print('WebSocket error: $error');
          _clean();
        });
  }

  void _clean() {
    print('WebSocket connection lost. Cleaning...');
    _channel.sink.close();
    print('WebSocket closed');
    _streamSubscription.cancel();
    print('Stream subscription canceled');
  }

  void _handleServerUpdate(Map<String, dynamic> data) async {
    print('Handling server update: $data');
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
    print('Initializing database...');
    String path = join(await getDatabasesPath(), 'car_maintenance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('Creating tables...');
        await db.execute(
          'CREATE TABLE car_maintenance_records(id INTEGER PRIMARY KEY, carModel TEXT, serviceType TEXT, serviceDate TEXT, serviceNotes TEXT)',
        );
        await db.execute(
          'CREATE TABLE pending_operations(id INTEGER PRIMARY KEY AUTOINCREMENT, operation TEXT, record TEXT)',
        );
      },
      onOpen: (db) async {
        print('Opening database...');
        await db.execute('DROP TABLE IF EXISTS car_maintenance_records');
        await db.execute('DROP TABLE IF EXISTS pending_operations');
        await db.execute(
          'CREATE TABLE car_maintenance_records(id INTEGER PRIMARY KEY, carModel TEXT, serviceType TEXT, serviceDate TEXT, serviceNotes TEXT)',
        );
        await db.execute(
          'CREATE TABLE pending_operations(id INTEGER PRIMARY KEY AUTOINCREMENT, operation TEXT, record TEXT)',
        );
      },
    );
  }

  Future<void> addPendingOperation(
      String operation, CarMaintenanceRecord record) async {
    print('Adding pending operation: $operation, record: $record');
    final db = await database;
    await db.insert(
      'pending_operations',
      {
        'operation': operation,
        'record': jsonEncode(record.toMap()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> processPendingOperations() async {
    print('Processing pending operations...');
    final db = await database;
    final List<Map<String, dynamic>> operations =
        await db.query('pending_operations');

    for (var operation in operations) {
      final record =
          CarMaintenanceRecord.fromMap(jsonDecode(operation['record']));
      print('Processing operation: ${operation['operation']}, record: $record');
      switch (operation['operation']) {
        case 'add':
          await deleteRecord(record.id);
          await insertRecord(record);
          break;
        case 'update':
          await updateRecord(record);
          break;
        case 'delete':
          await deleteRecord(record.id);
          break;
      }
      await db.delete('pending_operations',
          where: 'id = ?', whereArgs: [operation['id']]);
    }
  }

  Future<void> insertRecord(CarMaintenanceRecord record) async {
    print('Inserting record: $record');
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
    if (response.statusCode != 201) {
      print('Failed to insert record: $record');
    } else {
      final serverRecord =
          CarMaintenanceRecord.fromMap(jsonDecode(response.body));
      await db.insert(
        'car_maintenance_records',
        serverRecord.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> insertRecordLocally(CarMaintenanceRecord record) async {
    print('Inserting record locally: $record');
    final db = await database;
    await db.insert(
      'car_maintenance_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CarMaintenanceRecord>> refreshRecords() async {
    print('Refreshing records...');
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('car_maintenance_records');
    return List.generate(maps.length, (i) {
      return CarMaintenanceRecord.fromMap(maps[i]);
    });
  }

  Future<List<CarMaintenanceRecord>> getRecords() async {
    print('Getting records...');
    final db = await database;

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
      print('Failed to fetch records from server');
    }

    final List<Map<String, dynamic>> maps =
        await db.query('car_maintenance_records');
    return List.generate(maps.length, (i) {
      return CarMaintenanceRecord.fromMap(maps[i]);
    });
  }

  Future<void> updateRecord(CarMaintenanceRecord record) async {
    print('Updating record: $record');
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
    if (response.statusCode != 204) {
      print('Failed to update record: $record');
    }
    await db.update(
      'car_maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> updateRecordLocally(CarMaintenanceRecord record) async {
    print('Updating record locally: $record');
    final db = await database;
    await db.update(
      'car_maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(int id) async {
    print('Deleting record: $id');
    final db = await database;
    final response =
        await http.delete(Uri.parse('$apiUrl/CarMaintenanceRecords/$id'));

    await db.delete(
      'car_maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRecordLocally(int id) async {
    print('Deleting record locally: $id');
    final db = await database;
    await db.delete(
      'car_maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUnusedId() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('car_maintenance_records');
    final ids = List.generate(maps.length, (i) {
      return CarMaintenanceRecord.fromMap(maps[i]).id;
    });
    return ids.isEmpty ? 1 : ids.reduce((a, b) => a > b ? a : b) + 1;
  }
}
