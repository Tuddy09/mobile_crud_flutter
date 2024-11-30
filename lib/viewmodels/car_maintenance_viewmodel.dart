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
      id: _newRecordId(),
      carModel: carModel,
      serviceType: serviceType,
      serviceDate: serviceDate,
      serviceNotes: serviceNotes,
    );
    await _repository.insertRecord(newRecord);
    _records.add(newRecord);
    notifyListeners();
  }

  int _newRecordId() {
    final ids = _records.map((record) => record.id).toList();
    return (ids.isNotEmpty
            ? ids.reduce((value, element) => value > element ? value : element)
            : 0) +
        1;
  }

  Future<void> updateRecord(CarMaintenanceRecord record) async {
    await _repository.updateRecord(record);
    final index = _records.indexWhere((element) => element.id == record.id);
    if (index >= 0) {
      _records[index] = record;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(int id) async {
    await _repository.deleteRecord(id);
    _records.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  CarMaintenanceRecord? getRecord(int id) {
    return _records.firstWhere((element) => element.id == id,
        orElse: () => CarMaintenanceRecord(
              id: -1,
              carModel: '',
              serviceType: '',
              serviceDate: '',
              serviceNotes: '',
            ));
  }
}
