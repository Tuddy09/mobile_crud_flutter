import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import '../models/car_maintenance_record.dart';
import '../repository/car_maintenance_repository.dart';
import 'package:http/http.dart' as http;

class CarMaintenanceViewModel extends ChangeNotifier {
  final CarMaintenanceRepository _repository = CarMaintenanceRepository();
  List<CarMaintenanceRecord> _records = [];
  bool _isOffline = false;
  final List<CarMaintenanceRecord> _addedRecordsWhenOffline = [];

  UnmodifiableListView<CarMaintenanceRecord> get records =>
      UnmodifiableListView(_records);

  bool get isOffline => _isOffline;

  CarMaintenanceViewModel() {
    _loadRecords();
    _checkConnectivity();
    Timer.periodic(Duration(seconds: 5), (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _loadRecords() async {
    print('Loading records...');
    _records = await _repository.getRecords();
    print('Records loaded: $_records');
    notifyListeners();
  }

  Future<void> _checkConnectivity() async {
    print('Checking connectivity...');
    bool previousState = _isOffline;
    try {
      final response = await http
          .get(Uri.parse('http://192.168.100.10:5129/api/Health'))
          .timeout(Duration(seconds: 1));
      _isOffline = response.statusCode != 200;
      print('Connectivity check: ${_isOffline ? "Offline" : "Online"}');
    } catch (e) {
      _isOffline = true;
      print('Connectivity check failed: $e');
    }
    if (!_isOffline && previousState) {
      _repository.initializeWebSocket();
      await _repository.processPendingOperations();
      _records = await _repository.refreshRecords();
    }
    notifyListeners();
  }

  Future<void> addRecord(String carModel, String serviceType,
      String serviceDate, String serviceNotes) async {
    print('Adding record...');
    final unusedId = await _repository.getUnusedId();
    final newRecord = CarMaintenanceRecord(
      id: unusedId,
      carModel: carModel,
      serviceType: serviceType,
      serviceDate: serviceDate,
      serviceNotes: serviceNotes,
    );
    if (_isOffline) {
      print('Offline: Adding record to pending operations');
      await _repository.addPendingOperation('add', newRecord);
      await _repository.insertRecordLocally(newRecord);
      _addedRecordsWhenOffline.add(newRecord);
    } else {
      print('Online: Adding record to database');
      await _repository.insertRecord(newRecord);
    }
    _records = await _repository.refreshRecords();
    print('Record added: $newRecord');
    notifyListeners();
  }

  Future<void> updateRecord(CarMaintenanceRecord record) async {
    print('Updating record...');
    if (_isOffline) {
      print('Offline: Adding update to pending operations');
      await _repository.addPendingOperation('update', record);
      await _repository.updateRecordLocally(record);
    } else {
      print('Online: Updating record in database');
      await _repository.updateRecord(record);
    }
    _records = await _repository.refreshRecords();
    print('Record updated: $record');
    notifyListeners();
  }

  Future<void> deleteRecord(int id) async {
    print('Deleting record...');
    if (_isOffline) {
      final record = getRecord(id);
      if (record != null) {
        print('Offline: Adding delete to pending operations');
        await _repository.addPendingOperation('delete', record);
        await _repository.deleteRecordLocally(id);
      }
    } else {
      print('Online: Deleting record from database');
      await _repository.deleteRecord(id);
    }
    _records = await _repository.refreshRecords();
    print('Record deleted: $id');
    notifyListeners();
  }

  CarMaintenanceRecord? getRecord(int id) {
    return _records.firstWhere((element) => element.id == id,
        orElse: () => CarMaintenanceRecord(
            id: 0,
            carModel: '',
            serviceType: '',
            serviceDate: '',
            serviceNotes: ''));
  }
}
