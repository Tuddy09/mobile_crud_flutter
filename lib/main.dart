import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/car_maintenance_viewmodel.dart';
import 'views/home_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CarMaintenanceViewModel(), // Initialize ViewModel
      child: MaterialApp(
        title: 'Car Maintenance Records',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeView(), // Set HomeView as the starting screen
      ),
    );
  }
}
