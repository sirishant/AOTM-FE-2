import 'package:aotm_fe_2/models/workshop.dart';

class Dispenser {
  final int dispenserNo;
  final String alertLevel;
  final String dispenserName;
  final int maxX;
  final int maxZ;
  final Workshop workshop;

  Dispenser({
    required this.dispenserNo,
    required this.alertLevel,
    required this.dispenserName,
    required this.maxX,
    required this.maxZ,
    required this.workshop,
  });

  factory Dispenser.fromJson(Map<String, dynamic> json) {
    return Dispenser(
      dispenserNo: json['dispenserNo'],
      alertLevel: json['alertLevel'],
      dispenserName: json['dispenserName'],
      maxX: json['maxX'],
      maxZ: json['maxZ'],
      workshop: Workshop.fromJson(json['workshop']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dispenserNo': dispenserNo,
      'alertLevel': alertLevel,
      'dispenserName': dispenserName,
      'maxX': maxX,
      'maxZ': maxZ,
      'workshop': workshop.toJson(),
    };
  }

  @override
  String toString() {
    return 'Dispenser{dispenserNo: $dispenserNo, alertLevel: $alertLevel, dispenserName: $dispenserName, maxX: $maxX, maxZ: $maxZ, workshop: $workshop}';
  }
}

enum AlertLevel {
  LOW,
  MEDIUM,
  HIGH
}