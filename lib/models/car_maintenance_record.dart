class CarMaintenanceRecord {
  final int id;
  final String carModel;
  final String serviceType;
  final String serviceDate;
  final String serviceNotes;

  CarMaintenanceRecord({
    required this.id,
    required this.carModel,
    required this.serviceType,
    required this.serviceDate,
    required this.serviceNotes,
  });

  CarMaintenanceRecord copyWith({
    int? id,
    String? carModel,
    String? serviceType,
    String? serviceDate,
    String? serviceNotes,
  }) {
    return CarMaintenanceRecord(
      id: id ?? this.id,
      carModel: carModel ?? this.carModel,
      serviceType: serviceType ?? this.serviceType,
      serviceDate: serviceDate ?? this.serviceDate,
      serviceNotes: serviceNotes ?? this.serviceNotes,
    );
  }
}
