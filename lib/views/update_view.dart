import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/car_maintenance_viewmodel.dart';
import '../models/car_maintenance_record.dart';

class UpdateRecordScreen extends StatefulWidget {
  const UpdateRecordScreen({super.key});

  @override
  UpdateRecordScreenState createState() => UpdateRecordScreenState();
}

class UpdateRecordScreenState extends State<UpdateRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late String carModel;
  late String serviceType;
  late String serviceDate;
  late String serviceNotes;

  String? carModelError;
  String? serviceTypeError;
  String? serviceDateError;
  String? serviceNotesError;

  late int recordId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel =
        Provider.of<CarMaintenanceViewModel>(context, listen: false);
    recordId = ModalRoute.of(context)!.settings.arguments as int;
    final record = viewModel.getRecord(recordId);
    carModel = record?.carModel ?? '';
    serviceType = record?.serviceType ?? '';
    serviceDate = record?.serviceDate ?? '';
    serviceNotes = record?.serviceNotes ?? '';
  }

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

  void _updateRecord() {
    if (_validateFields()) {
      final viewModel = Provider.of<CarMaintenanceViewModel>(context, listen: false);
      final updatedRecord = CarMaintenanceRecord(
        id: recordId,
        carModel: carModel,
        serviceType: serviceType,
        serviceDate: serviceDate,
        serviceNotes: serviceNotes,
      );

      if (viewModel.isOffline) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Offline'),
              content: const Text('You are currently offline. The record will be updated locally and synced when you are back online.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    viewModel.updateRecord(updatedRecord);
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
                ),
              ],
            );
          },
        );
      } else {
        viewModel.updateRecord(updatedRecord);
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
                  'Update Record',
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
                  onPressed: _updateRecord,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
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
