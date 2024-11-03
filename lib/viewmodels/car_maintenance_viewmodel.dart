import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../models/car_maintenance_record.dart';

class CarMaintenanceViewModel extends ChangeNotifier {
  final List<CarMaintenanceRecord> _records = [
    CarMaintenanceRecord(
      id: '1',
      carModel: 'Toyota Corolla',
      serviceType: 'Oil Change',
      serviceDate: '2021-10-01',
      serviceNotes: 'Changed oil and filter',
    ),
    CarMaintenanceRecord(
      id: '2',
      carModel: 'Honda Civic',
      serviceType: 'Tire Rotation',
      serviceDate: '2021-10-02',
      serviceNotes: 'Rotated tires',
    ),
    CarMaintenanceRecord(
      id: '3',
      carModel: 'Ford F-150',
      serviceType: 'Brake Inspection',
      serviceDate: '2021-10-03',
      serviceNotes: 'Inspected brakes',
    ),
    CarMaintenanceRecord(
      id: '4',
      carModel: 'Chevrolet Silverado',
      serviceType: 'Air Filter Replacement',
      serviceDate: '2021-10-04',
      serviceNotes: 'Replaced air filter',
    ),
    CarMaintenanceRecord(
      id: '5',
      carModel: 'Jeep Wrangler',
      serviceType: 'Coolant Flush',
      serviceDate: '2021-10-05',
      serviceNotes: 'Flushed coolant',
    ),
    CarMaintenanceRecord(
      id: '6',
      carModel: 'Subaru Outback',
      serviceType: 'Battery Replacement',
      serviceDate: '2021-10-06',
      serviceNotes: 'Replaced battery',
    ),
    CarMaintenanceRecord(
      id: '7',
      carModel: 'Nissan Altima',
      serviceType: 'Spark Plug Replacement',
      serviceDate: '2021-10-07',
      serviceNotes: 'Replaced spark plugs',
    ),
    CarMaintenanceRecord(
      id: '8',
      carModel: 'Hyundai Sonata',
      serviceType: 'Transmission Fluid Change',
      serviceDate: '2021-10-08',
      serviceNotes: 'Changed transmission fluid',
    ),
    CarMaintenanceRecord(
      id: '9',
      carModel: 'Kia Sportage',
      serviceType: 'Timing Belt Replacement',
      serviceDate: '2021-10-09',
      serviceNotes: 'Replaced timing belt',
    ),
    CarMaintenanceRecord(
      id: '10',
      carModel: 'Mazda CX-5',
      serviceType: 'Wheel Alignment',
      serviceDate: '2021-10-10',
      serviceNotes: 'Aligned wheels',
    ),
  ];

  UnmodifiableListView<CarMaintenanceRecord> get records =>
      UnmodifiableListView(_records);

  void addRecord(CarMaintenanceRecord record) {
    _records.add(record);
    notifyListeners();
  }

  void updateRecord(CarMaintenanceRecord record) {
    final index = _records.indexWhere((element) => element.id == record.id);
    if (index >= 0) {
      _records[index] = record;
      notifyListeners();
    }
  }

  void deleteRecord(String id) {
    _records.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  CarMaintenanceRecord? getRecord(String id) {
    return _records.firstWhere((element) => element.id == id,
        orElse: () => CarMaintenanceRecord(
            id: '',
            carModel: '',
            serviceType: '',
            serviceDate: '',
            serviceNotes: ''));
  }
}
