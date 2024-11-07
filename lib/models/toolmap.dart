import 'package:aotm_fe_2/models/tool.dart';
import 'package:aotm_fe_2/models/coordinate.dart';
import 'package:aotm_fe_2/models/dispenser.dart';

class Toolmap {
  final int id;
  final Tool tool;
  final Coordinate coordinate;
  final Dispenser dispenser;
  final int currentQuantity;
  final int maxQuantity;
  final AlertLevel alertLevel;

  Toolmap({
    required this.id,
    required this.tool,
    required this.coordinate,
    required this.dispenser,
    required this.currentQuantity,
    required this.maxQuantity,
    required this.alertLevel,
  });

  factory Toolmap.fromJson(Map<String, dynamic> json) {
    return Toolmap(
      id: json['id'],
      tool: Tool.fromJson(json['tool']),
      coordinate: Coordinate.fromJson(json['coordinate']),
      dispenser: Dispenser.fromJson(json['dispenser']),
      currentQuantity: json['currentQuantity'],
      maxQuantity: json['maxQuantity'],
      alertLevel: json['alertLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool': tool.toJson(),
      'coordinate': coordinate.toJson(),
      'dispenser': dispenser.toJson(),
      'currentQuantity': currentQuantity,
      'maxQuantity': maxQuantity,
      'alertLevel': alertLevel,
    };
  }

  @override
  String toString() {
    return 'Toolmap{id: $id, tool: $tool, coordinate: $coordinate, dispenser: $dispenser, currentQuantity: $currentQuantity, maxQuantity: $maxQuantity, alertLevel: $alertLevel}';
  }
}