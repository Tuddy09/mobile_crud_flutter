import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import '../models/car_maintenance_record.dart';
import '../repository/car_maintenance_repository.dart';

class CarMaintenanceViewModel extends ChangeNotifier {
  final CarMaintenanceRepository _repository = CarMaintenanceRepository();
  List<CarMaintenanceRecord> _records = [];

  UnmodifiableListView<CarMaintenanceRecord> get records =>
      UnmodifiableListView(_records);

  CarMaintenanceViewModel() {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    _records = await _repository.getRecords();
    notifyListeners();
  }

  Future<void> addRecord(String carModel, String serviceType,
      String serviceDate, String serviceNotes) async {
    final newRecord = CarMaintenanceRecord(
      id: 0,
      carModel: carModel,
      serviceType: serviceType,
      serviceDate: serviceDate,
      serviceNotes: serviceNotes,
    );
    await _repository.insertRecord(newRecord);
    _records = await _repository.refreshRecords();
    notifyListeners();
  }

  Future<void> updateRecord(CarMaintenanceRecord record) async {
    await _repository.updateRecord(record);
    _records = await _repository.refreshRecords();
    notifyListeners();
  }

  Future<void> deleteRecord(int id) async {
    await _repository.deleteRecord(id);
    _records = await _repository.refreshRecords();
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
