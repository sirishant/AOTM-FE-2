import 'package:aotm_fe_2/models/tool.dart';

import 'employee.dart';
import 'workshop.dart';
import 'machine.dart';

class Job {
  final int jobId;
  final String title;
  final String description;
  final int createdAt;
  final String status;
  final List<Employee> employees;
  final Workshop workshop;
  final Machine machine;
  final List<JobTool> jobTools;

  Job({
    required this.jobId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.employees,
    required this.workshop,
    required this.machine,
    required this.jobTools,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['jobId'],
      title: json['title'],
      description: json['description'],
      createdAt: json['createdAt'],
      status: json['status'],
      employees: List<Employee>.from(
          json['employees'].map((employee) => Employee.fromJson(employee))),
      workshop: Workshop.fromJson(json['workshop']),
      machine: Machine.fromJson(json['machine']),
      jobTools: List<JobTool>.from(
          json['jobTools'].map((jobTools) => JobTool.fromJson(jobTools))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'status': status,
      'employees': employees.map((employee) => employee.toJson()).toList(),
      'workshop': workshop.toJson(),
      'machine': machine.toJson(),
      'jobTools': jobTools.map((jobTools) => jobTools.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Job{jobId: $jobId, title: $title, description: $description, createdAt: $createdAt, status: $status, employees: $employees, workshop: $workshop, machine: $machine, jobTools: $jobTools}';
  }
}

class JobTool {
  final int id;
  final Tool tool;
  final int quantity;
  final int takenQuantity;

  JobTool({
    required this.id,
    required this.tool,
    required this.quantity,
    required this.takenQuantity,
  });

  factory JobTool.fromJson(Map<String, dynamic> json) {
    return JobTool(
      id: json['id'],
      tool: Tool.fromJson(json['tool']),
      quantity: json['quantity'],
      takenQuantity: json['takenQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool': tool.toJson(),
      'quantity': quantity,
      'takenQuantity': takenQuantity,
    };
  }

  @override
  String toString() {
    return 'JobTools{id: $id, tool: $tool, quantity: $quantity, takenQuantity: $takenQuantity}';
  }
}