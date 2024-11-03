import 'package:flutter/material.dart';
import 'package:mobile_crud_flutter/views/read_view.dart';
import 'package:provider/provider.dart';
import 'viewmodels/car_maintenance_viewmodel.dart';
import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CarMaintenanceViewModel(), // Initialize ViewModel
      child: MaterialApp(
        title: 'Car Maintenance Records',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeView(),
          '/details': (context) => MaintenanceRecordDetailsScreen(),
        },
      ),
    );
  }
}
