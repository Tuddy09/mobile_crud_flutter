import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/car_maintenance_viewmodel.dart';

class AddNewRecordScreen extends StatefulWidget {
  const AddNewRecordScreen({super.key});

  @override
  AddNewRecordScreenState createState() => AddNewRecordScreenState();
}

class AddNewRecordScreenState extends State<AddNewRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  String carModel = '';
  String serviceType = '';
  String serviceDate = '';
  String serviceNotes = '';

  String? carModelError;
  String? serviceTypeError;
  String? serviceDateError;
  String? serviceNotesError;

  bool _validateFields() {
    bool isValid = true;
    setState(() {
      carModelError = carModel.isEmpty ? 'Car Model is required' : null;
      serviceTypeError =
      serviceType.isEmpty ? 'Service Type is required' : null;
      serviceDateError = serviceDate.isEmpty
          ? 'Service Date is required'
          : !RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(serviceDate)
          ? 'Service Date must be in YYYY-MM-DD format'
          : null;
      serviceNotesError =
      serviceNotes.isEmpty ? 'Service Notes are required' : null;
      isValid = carModelError == null &&
          serviceTypeError == null &&
          serviceDateError == null &&
          serviceNotesError == null;
    });
    return isValid;
  }

  void _saveRecord() {
    if (_validateFields()) {
      final viewModel = Provider.of<CarMaintenanceViewModel>(context, listen: false);
      if (viewModel.isOffline) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Offline'),
              content: const Text('You are currently offline. The record will be saved locally and synced when you are back online.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.addRecord(carModel, serviceType, serviceDate, serviceNotes);
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
                ),
              ],
            );
          },
        );
      } else {
        viewModel.addRecord(carModel, serviceType, serviceDate, serviceNotes);
        Navigator.pop(context); // Navigate back to the previous screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040633),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Add New Record',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                _buildTextField(
                  label: 'Car Model',
                  value: carModel,
                  onChanged: (value) => setState(() => carModel = value),
                  errorText: carModelError,
                ),
                _buildTextField(
                  label: 'Service Type',
                  value: serviceType,
                  onChanged: (value) => setState(() => serviceType = value),
                  errorText: serviceTypeError,
                ),
                _buildTextField(
                  label: 'Service Date',
                  value: serviceDate,
                  onChanged: (value) => setState(() => serviceDate = value),
                  errorText: serviceDateError,
                  hintText: 'YYYY-MM-DD',
                ),
                _buildTextField(
                  label: 'Service Notes',
                  value: serviceNotes,
                  onChanged: (value) => setState(() => serviceNotes = value),
                  errorText: serviceNotesError,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveRecord,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    String? errorText,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          errorText: errorText,
          labelStyle: const TextStyle(color: Colors.white),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}