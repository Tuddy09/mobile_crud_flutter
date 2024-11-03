import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/car_maintenance_viewmodel.dart';
import '../models/car_maintenance_record.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CarMaintenanceViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF040633),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new record screen
          Navigator.of(context).pushNamed('/addNewRecord');
        },
        backgroundColor: const Color(0xFFFFE5B4),
        child: const Icon(Icons.add, color: Colors.red),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0), // Add padding from the top
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Home',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Maintenance Records List',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Expanded(
                child: MaintenanceRecordList(records: viewModel.records),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MaintenanceRecordList extends StatelessWidget {
  final List<CarMaintenanceRecord> records;

  const MaintenanceRecordList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        return MaintenanceRecordItem(record: records[index]);
      },
    );
  }
}

class MaintenanceRecordItem extends StatelessWidget {
  final CarMaintenanceRecord record;

  const MaintenanceRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
            '${record.serviceDate}: ${record.carModel} - ${record.serviceType}'),
        onTap: () {
          // Navigate to details page for this record
          Navigator.of(context).pushNamed('/details', arguments: record.id);
        },
      ),
    );
  }
}
