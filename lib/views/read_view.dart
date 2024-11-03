import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/car_maintenance_viewmodel.dart';

class MaintenanceRecordDetailsScreen extends StatelessWidget {
  const MaintenanceRecordDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as int;
    final viewModel = Provider.of<CarMaintenanceViewModel>(context);
    final record = viewModel.getRecord(id);

    return Scaffold(
      backgroundColor: const Color(0xFF040633),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Car Model: ${record?.carModel}",
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  Text(
                    "Service Type: ${record?.serviceType}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "Service Date: ${record?.serviceDate}",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    "Service Notes: ${record?.serviceNotes}",
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/update", arguments: id);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text("Update"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteDialog(context, viewModel, record!.id);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, CarMaintenanceViewModel viewModel, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.deleteRecord(id);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
