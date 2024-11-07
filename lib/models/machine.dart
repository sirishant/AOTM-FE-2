import 'workshop.dart';
import 'employee.dart';

class Machine {
  final int machineNo;
  final String machineName;
  final Workshop workshop;
  final List<Employee> employees;

  Machine({
    required this.machineNo,
    required this.machineName,
    this.workshop = const Workshop.nullWorkshop(),
    this.employees = const [],
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      machineNo: json['machineNo'],
      machineName: json['machineName'],
      workshop: json['workshop'] != null ? Workshop.fromJson(json['workshop']) : Workshop.nullWorkshop(),
      employees: json['employees'] != null
          ? List<Employee>.from(json['employees'].map((employee) => Employee.fromJson(employee)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machineNo': machineNo,
      'machineName': machineName,
      'workshop': workshop.toJson(),
      'employees': employees.map((employee) => employee.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Machine{machineNo: $machineNo, machineName: $machineName, workshop: $workshop, employees: $employees}';
  }

}